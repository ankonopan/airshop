defmodule AirShop.AirFrance.API do
  import SweetXml

  @type error :: {:error, map}
  @type success :: {:ok, map}

  @doc """
  Find the cheapest offer for a given vector of departure, arrival and date.

  Note:
  Case 1: The API is called by commands `AirShop.AirFrance.API.cheapestOffer(departure, arrival, date)`
  Depending on the amount of commands this API exposes I would refactor the module into a set of submodules each of them handling a single execution.
  AirShop.AirFrance.API.CheapestOffer will be a case where only this action is executed.

  defmodule AirShop.AirFrance.API.CheapestOffer do
    def execute(departure, arrival, date) do
      ...
    end
  end

  Case 2: The API is called as it own server AirShop.AirFrance.API.call({:cheapest_offer, departure, arrival, date})

  The separation of function into its own command modules makes a bit more sense here as the API GenServer will work as a dispatcher of API request.
  """
  @spec cheapestOffer(String.t(), String.t(), String.t()) :: success | error
  def cheapestOffer(departure, arrival, date) do
    case call({:search, departure, arrival, date})
         |> process_response do
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

  @spec call(tuple) :: String.t()
  defp call(request_params) do
    AirShop.AirFrance.Application.call(request_params)
  end

  @doc """
  Process a response from the pool, detect http errors or returns a valid response
  """
  @spec process_response({atom, String}) :: success | error
  defp process_response({:ok, response}) do
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

      SweetXml.xpath(r, ~x"//h1/text()"l) == ['Developer Over Rate'] ->
        {:error, type: :request_rate_execeded, errors: []}

      true ->
        {:ok, r}
    end
  end

  @doc """
  Process a response from the pool and resque the API from unknow errors
  """
  @spec process_response({atom, String}) :: success | error
  defp process_response({:error, error}) do
    IO.inspect("Broadcast to a developer that one of your worker died with an unknown reason")
    {:error, error}
  end
end
