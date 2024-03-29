defmodule AirShop do
  use GenServer

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(stack) do
    {:ok, stack}
  end

  @doc """
  Performs a concurrent request to all registered Airline Services to search for the cheapest offer.
  """
  def handle_call({:cheapestOffer, departure, arrival, date} = req, _from, state) do
    airlines_apis = [AirShop.AirFrance.Service, AirShop.BritishAirways.Service]

    result =
      Task.async_stream(airlines_apis, fn api ->
        GenServer.call(api, {:cheapestOffer, departure, arrival, date})
      end)
      |> Enum.to_list()
      # Do something about errors here. Maybe there is a case for product Owning
      |> Enum.filter(fn r ->
        {_, {status, _, response}} = r
        status == :ok
      end)
      |> find_min_amount_by(fn {:ok, {:ok, _, amount}} -> amount end)

    response =
      case result do
        [] ->
          {:empty}

        {:ok, {:ok, airline, amount}} ->
          {:ok, %{airline: airline, amount: amount}}
      end

    {:reply, response, state}
  end

  defp find_min_amount_by([], fun), do: []

  defp find_min_amount_by(data, fun) do
    Enum.min_by(data, fun)
  end
end
