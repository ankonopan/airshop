defmodule AirShop.BritishAirways.Actions.CheapestOffer do
  import SweetXml

  @type error :: {:error, map}
  @type success :: {:ok, map}

  @doc """
   Find the cheapest offer for a given vector of departure, arrival and date.
  """
  @spec process(tuple) :: success | error
  def process(response) do
    case response |> process_errors do
      {:ok, parsed_response} ->
        min =
          parsed_response
          |> SweetXml.xpath(~x"//AirlineOffers/AirlineOffer"l,
            total: ~x"./TotalPrice/SimpleCurrencyPrice/text()" |> transform_by(&List.to_float/1)
          )
          |> Enum.map(fn %{total: t} -> t end)
          |> Enum.min()

        {:ok, "BA", min}

      {:error, error} ->
        {:error, "BA", error}
    end
  end

  def process_errors({:ok, response}) do
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
               code: ~x"./@Code" |> transform_by(&List.to_string/1),
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

      true ->
        {:ok, r}
    end
  end
end
