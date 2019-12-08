ExUnit.start()

defmodule AirShopMock do
  @moduledoc """

    Provides a mocked AirShop service that responds once with any data that was previously casted into it.

  """
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def handle_call(_req, _from, response) do
    {:reply, response, nil}
  end

  def handle_cast({:respond_with, response}, _state) do
    {:noreply, response}
  end
end
