defmodule WebApi.CheapestOfferTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mox
  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  @opts WebApi.CheapestOffer.init([])

  test "returns the cheapest Offer when the AirShop service is available" do
    {:ok, pid} = GenServer.start_link(AirShopMock, [], name: AirShopMock)
    IO.inspect("Mocked AirShop server started with pid: #{inspect(pid)}")
    GenServer.cast(AirShopMock, {:respond_with, {:ok, %{amount: 55.19, airline: "BA"}}})

    resp =
      conn(:get, "/?origin=TXL&destination=LHR&departureDate=2020-01-01")
      |> Plug.Conn.fetch_query_params()
      |> WebApi.CheapestOffer.call(@opts)

    # Assert the response and status
    assert resp.state == :sent
    assert resp.status == 200
    assert resp.resp_body == "{\"data\":{\"amount\":55.19,\"airline\":\"BA\"}}"
  end

  test "returns a 502 error with the AirShop service is unavailable " do
    resp =
      conn(:get, "/?origin=TXL&destination=LHR&departureDate=2020-01-01")
      |> Plug.Conn.fetch_query_params()
      |> WebApi.CheapestOffer.call(@opts)

    # Assert the response and status
    assert resp.state == :sent
    assert resp.status == 502
    assert resp.resp_body == "{\"error\":\"air_shop_offline\"}"
  end
end
