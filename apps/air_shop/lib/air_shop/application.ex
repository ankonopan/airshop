defmodule AirShop.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: AirShop.Worker.start_link(arg)
      {AirShop.AirFrance.Application,
       %{
         pool: %{
           size: Application.fetch_env!(:air_shop, :airfranceklm)[:pool_size],
           max_overflow: Application.fetch_env!(:air_shop, :airfranceklm)[:pool_max_overflow]
         },
         worker: %{
           endpoint: Application.fetch_env!(:air_shop, :airfranceklm)[:endpoint],
           api_key: Application.fetch_env!(:air_shop, :airfranceklm)[:api_key]
         }
       }}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AirShop.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
