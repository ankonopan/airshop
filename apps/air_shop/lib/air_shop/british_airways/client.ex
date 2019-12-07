defmodule AirShop.BritishAirways.Client do
  alias AirShop.BritishAirways.Request

  @doc """
  Creates a base request for British Airways

  ## Examples
    iex> req = AirShop.BritishAirways.Client.build("url", "an api key")
    iex> req[:endpoint]
    "url"
    iex> req[:headers][:"Client-Key"]
    "an api key"
  """
  def build(endpoint, api_key) do
    %{
      endpoint: endpoint,
      headers: [
        "Client-Key": api_key,
        "Content-Type": "application/xml",
        Soapaction: "AirShoppingV01"
      ]
    }
  end

  @doc """
  Creates a search request for British Airways

  ## Examples
    iex> search_req = AirShop.BritishAirways.Client.search(%{endpoint: "a", headers: "b"},"TXL", "LHR", "2020-01-01")
    iex> String.match?(search_req[:body], ~r"TXL")
    true
  """
  def search(%{endpoint: e, headers: h}, departure, arrival, date) do
    b =
      AirShop.BritishAirways.Request.build(departure, arrival, date)
      |> AirShop.Request.encode()

    %{endpoint: e, headers: h, body: b}
  end

  @doc """
  Calls the API request on British Airways endpoint
  """
  def call(%{endpoint: e, headers: h, body: b}) do
    HTTPoison.post(e, b, h)
  end
end
