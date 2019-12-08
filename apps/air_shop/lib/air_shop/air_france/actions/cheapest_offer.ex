defmodule AirShop.AirFrance.Actions.CheapestOffer do
  import SweetXml

  @type error :: {:error, map}
  @type success :: {:ok, map}

  @doc """
   Find the cheapest offer for a given vector of departure, arrival and date.
  """
  @spec process(tuple) :: success | error
  def process(response) do
    case response |> process_errors do
      {:ok, response} ->
        min =
          response
          |> SweetXml.xpath(~x"//AirlineOffers/Offer"l,
            total:
              ~x"./TotalPrice/DetailCurrencyPrice/Total/text()" |> transform_by(&List.to_float/1)
          )
          |> Enum.map(fn %{total: t} -> t end)
          |> Enum.min()

        {:ok, "AFKL", min}

      {:error, error} ->
        {:error, "AFKL", error}
    end
  end

  @doc """
  Process a response from the pool, detect http errors or returns a valid response
  """
  @spec process_errors({atom, String}) :: success | error
  defp process_errors({:ok, response}) do
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

      SweetXml.xpath(r, ~x"//h1/text()"l) == ['Developer Inactive'] ->
        {:error, type: :invalid_api_key, errors: []}

      SweetXml.xpath(r, ~x"//h1/text()"l) == ['Developer Over Rate'] ->
        {:error, type: :request_rate_execeded, errors: []}

      true ->
        {:ok, r}
    end
  end

  @doc """
  Process a response from the pool and resque the API from unknow errors
  """
  @spec process_errors({atom, String}) :: success | error
  defp process_errors({:error, error}) do
    IO.inspect("Broadcast to a developer that one of your worker died with an unknown reason")
    {:error, error}
  end
end
