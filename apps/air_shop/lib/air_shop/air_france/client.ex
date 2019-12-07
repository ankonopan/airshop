defmodule AirShop.AirFrance.Client do
  alias AirShop.AirFrance.Request

  @doc """
  Creates a base request for Air France KLM API

  ## Examples
    iex> req = AirShop.AirFrance.Client.build("url", "an api key")
    iex> req[:endpoint]
    "url"
    iex> req[:headers][:api_key]
    "an api key"
  """
  def build(endpoint, api_key) do
    %{
      endpoint: endpoint,
      headers: [
        api_key: api_key,
        "Content-Type": "text/xml",
        SOAPAction:
          '"http://www.af-klm.com/services/passenger/ProvideAirShopping/provideAirShopping"'
      ]
    }
  end

  @doc """
  Creates a search request for Air France KLM API

  ## Examples
    iex> search_req = AirShop.AirFrance.Client.search(%{endpoint: "a", headers: "b"},"TXL", "LHR", "2020-01-01")
    iex> String.match?(search_req[:body], ~r"TXL")
    true
  """
  def search(%{endpoint: e, headers: h}, departure, arrival, date) do
    b =
      Request.build(departure, arrival, date)
      |> AirShop.Request.encode()

    %{endpoint: e, headers: h, body: b}
  end

  @doc """
  Calls the API request on Air France endpoint
  """
  def call(%{endpoint: e, headers: h, body: b}) do
    HTTPoison.post(e, b, h)
  end
end
