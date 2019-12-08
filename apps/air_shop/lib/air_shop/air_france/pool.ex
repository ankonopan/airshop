defmodule AirShop.AirFrance.Pool do
  @moduledoc false

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @spec execute(tuple) :: String.t()
  def execute(request_params) do
    :poolboy.transaction(
      AirFrance.WorkersPool,
      fn pid ->
        GenServer.call(pid, request_params)
      end,
      60_000
    )
  end

  defp poolboy_config(args) do
    [
      {:name, {:local, AirFrance.WorkersPool}},
      {:worker_module, AirShop.AirFrance.SOAP.Worker},
      {:size, args[:size]},
      {:max_overflow, args[:max_overflow]}
    ]
  end

  def init(args) do
    children = [
      :poolboy.child_spec(
        AirFrance.WorkersPool,
        poolboy_config(args[:pool]),
        args[:worker]
      )
    ]

    opts = [strategy: :one_for_one, name: AirShop.AirFrance.Pool]
    Supervisor.init(children, opts)
  end
end
