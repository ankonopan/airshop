defmodule AirShop.AirFrance.Worker do
  alias AirShop.AirFrance.Client
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @spec init(map) :: tuple
  def init(state) do
    {:ok, state}
  end

  @spec handle_call(tuple, tuple, map) :: tuple
  def handle_call({:search, departure, arrival, date}, from, state) do
    {:ok, %HTTPoison.Response{body: body}} =
      Client.build(state[:endpoint], state[:api_key])
      |> Client.search(departure, arrival, date)
      |> Client.call()

    {:reply, body, state}
  end
end
