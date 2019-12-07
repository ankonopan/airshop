defmodule AirShop.BritishAirways.API do
  alias AirShop.BritishAirways.Client
  import SweetXml

  def cheapestOffer(departure, arrival, date) do
    {:ok, %HTTPoison.Response{body: body}} =
      Client.build(
        Application.fetch_env!(:air_shop, :british_airways)[:endpoint],
        Application.fetch_env!(:air_shop, :british_airways)[:api_key]
      )
      |> Client.search(departure, arrival, date)
      |> Client.call()

    min =
      body
      |> SweetXml.parse(namespace_conformant: true)
      |> SweetXml.xpath(~x"//AirlineOffer/TotalPrice/SimpleCurrencyPrice/text()"l)
      |> Enum.map(fn price -> List.to_float(price) end)
      |> Enum.min()

    %{amount: min, airline: "BA"}
  end
end
