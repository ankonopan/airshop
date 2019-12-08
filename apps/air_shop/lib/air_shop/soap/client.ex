defmodule AirShop.SOAP.Client do
  @callback build(String.t(), String.t()) :: map
  @callback search(map, String.t(), String.t(), String.t()) :: map
  @callback call(map) :: map
end
