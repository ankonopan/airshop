defmodule AirShop.BritishAirways.API do
  use GenServer

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(stack) do
    {:ok, stack}
  end

  def handle_call({:cheapestOffer, departure, arrival, date}, _from, state) do
    response =
      AirShop.BritishAirways.Pool.execute({:search, departure, arrival, date})
      |> AirShop.BritishAirways.Actions.CheapestOffer.process()

    {:reply, response, state}
  end
end
