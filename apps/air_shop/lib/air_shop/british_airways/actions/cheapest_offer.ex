defmodule AirShop.BritishAirways.Actions.CheapestOffer do
  import SweetXml

  @type error :: {:error, map}
  @type success :: {:ok, map}

  @doc """
   Find the cheapest offer for a given vector of departure, arrival and date.
  """
  @spec process(tuple) :: success | error
  def process(response) do
  end
end
