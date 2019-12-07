defmodule AirShop.AirFrance.API do
  import SweetXml

  @type error :: {:error, map}
  @type success :: {:ok, map}

  @spec cheapestOffer(String.t(), String.t(), String.t()) :: success | error
  def cheapestOffer(departure, arrival, date) do
    case call({:search, departure, arrival, date})
         |> process_response do
      {:ok, response} ->
        min =
          response
          |> SweetXml.xpath(~x"//Offers/Offer"l,
            total:
              ~x"./TotalPrice/DetailCurrencyPrice/Total/text()" |> transform_by(&List.to_float/1)
          )
          |> Enum.min()

        {:ok, %{amount: min, airline: "AFKL"}}

      error ->
        error
    end
  end

  @spec call(tuple) :: String.t()
  defp call(request_params) do
    GenServer.call(AirShop.AirFrance.Worker, request_params)
  end

  @spec process_response(String) :: success | error
  defp process_response(response) do
    r =
      response
      |> SweetXml.parse(namespace_conformant: true)

    cond do
      List.first(SweetXml.xpath(r, ~x"//Errors/Error/text()"l)) ->
        {:error,
         %{
           type: :system_error,
           errors:
             SweetXml.xpath(r, ~x"//Errors/Error"l,
               short_text: ~x"./@ShortText",
               code: ~x"./@Code" |> transform_by(&List.to_integer/1),
               text: ~x"./text()"
             )
         }}

      List.first(SweetXml.xpath(r, ~x"//faultstring/text()"l)) ->
        {:error,
         %{
           type: :request_error,
           errors: [
             text: SweetXml.xpath(r, ~x"//faultstring/text()"),
             code: SweetXml.xpath(r, ~x"//faultactor/text()")
           ]
         }}

      SweetXml.xpath(r, ~x"//h1/text()"l) == ['Developer Inactive'] ->
        {:error, type: :invalid_api_key, errors: []}

      true ->
        {:ok, r}
    end
  end
end
