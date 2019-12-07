defmodule AirShop.Request do
  @doc ~S"""
  Converts a Map request into a an XML body envelope

  ## Examples
    iex> xml_map = {"CoreQuery", [], [{"OriginDestinations", [], ["test"]}]}
    iex> AirShop.Request.encode(xml_map)
    "<CoreQuery><OriginDestinations>test</OriginDestinations></CoreQuery>"
  """
  def encode(request) do
    request
    |> XmlBuilder.generate()
    |> String.replace("\r", "")
    |> String.replace("\n", "")
    |> String.replace(~r/ {2,}/iu, "")
  end
end
