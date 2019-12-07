defmodule AirShop.AirFrance.API do
  alias AirShop.AirFrance.Client
  import SweetXml

  def cheapestOffer(departure, arrival, date) do
    {:ok, %HTTPoison.Response{body: body}} =
      Client.build(
        Application.fetch_env!(:air_shop, :airfranceklm)[:endpoint],
        Application.fetch_env!(:air_shop, :airfranceklm)[:api_key]
      )
      |> Client.search(departure, arrival, date)
      |> Client.call()

    min =
      body
      |> SweetXml.parse(namespace_conformant: true)
      |> SweetXml.xpath(~x"//Offer/TotalPrice/DetailCurrencyPrice/Total/text()"l)
      |> Enum.map(fn price -> List.to_float(price) end)
      |> Enum.min()

    %{amount: min, airline: "AFKL"}
  end
end
