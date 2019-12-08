defmodule WebApi.AirShopWrapper do
  @callback call(tuple) :: map
  @air_shop_process_name Application.get_env(:api, :air_shop_process_name)

  @doc """
  Calls the AirShop Application if is it alive. Otherwise it returns an erorr
  """
  @spec call(tuple) :: map
  def call(args) do
    case Process.whereis(@air_shop_process_name) do
      nil ->
        {:error, :air_shop_offline}

      pid ->
        GenServer.call(pid, args)
    end
  end
end
