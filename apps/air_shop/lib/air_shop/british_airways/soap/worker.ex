defmodule AirShop.BritishAirways.SOAP.Worker do
  alias AirShop.BritishAirways.SOAP.Client
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @spec init(map) :: tuple
  def init(state) do
    {:ok, state}
  end

  @spec handle_call(tuple, tuple, map) :: tuple
  def handle_call({:search, departure, arrival, date}, _from, state) do
    try do
      {:ok, %HTTPoison.Response{body: body}} =
        Client.build(state[:endpoint], state[:api_key])
        |> Client.search(departure, arrival, date)
        |> Client.call()

      {:reply, {:ok, body}, state}
    catch
      x ->
        {:stop, :server_error, {:error, "<h1>#{x}</h1>"}, state}
    end
  end
end
