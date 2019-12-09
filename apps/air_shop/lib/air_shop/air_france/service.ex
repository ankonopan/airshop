defmodule AirShop.AirFrance.Service do
  use GenServer

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(stack) do
    {:ok, stack}
  end

  def handle_call({:cheapestOffer, departure, arrival, date}, _from, state) do
    response =
      AirShop.AirFrance.Pool.execute({:search, departure, arrival, date})
      |> AirShop.AirFrance.Actions.CheapestOffer.process()

    {:reply, response, state}
  end
end
