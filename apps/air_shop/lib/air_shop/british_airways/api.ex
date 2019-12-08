defmodule AirShop.BritishAirways.API do
  use GenServer

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(stack) do
    {:ok, stack}
  end

  def handle_call({:cheapestOffer, departure, arrival, date}, _from, state) do
    response = {:error, "BA", %{type: :unimplemented, errors: []}}

    {:reply, response, state}
  end
end
