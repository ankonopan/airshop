defmodule AirShop.BritishAirways.Pool do
  @moduledoc false

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @spec execute(tuple) :: String.t()
  def execute(request_params) do
    :poolboy.transaction(
      BritishAirways.WorkersPool,
      fn pid ->
        GenServer.call(pid, request_params)
      end,
      60_000
    )
  end

  defp poolboy_config(args) do
    [
      {:name, {:local, BritishAirways.WorkersPool}},
      {:worker_module, AirShop.BritishAirways.SOAP.Worker},
      {:size, args[:size]},
      {:max_overflow, args[:max_overflow]}
    ]
  end

  def init(args) do
    children = [
      :poolboy.child_spec(
        BritishAirways.WorkersPool,
        poolboy_config(args[:pool]),
        args[:worker]
      )
    ]

    opts = [strategy: :one_for_one, name: AirShop.BritishAirways.Pool]
    Supervisor.init(children, opts)
  end
end
