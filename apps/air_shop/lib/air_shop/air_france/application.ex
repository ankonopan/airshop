defmodule AirShop.AirFrance.Application do
  @moduledoc false

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @spec call(tuple) :: String.t()
  def call(request_params) do
    :poolboy.transaction(
      AirShop.AirFrance,
      fn pid ->
        GenServer.call(pid, request_params)
      end,
      60_000
    )
  end

  defp poolboy_config(args) do
    [
      {:name, {:local, AirShop.AirFrance}},
      {:worker_module, AirShop.AirFrance.Worker},
      {:size, args[:size]},
      {:max_overflow, args[:max_overflow]}
    ]
  end

  def init(args) do
    children = [
      :poolboy.child_spec(AirShop.AirFrance, poolboy_config(args[:pool]), args[:worker])
    ]

    opts = [strategy: :one_for_one, name: AirShop.AirFrance.Application]
    Supervisor.init(children, opts)
  end
end
