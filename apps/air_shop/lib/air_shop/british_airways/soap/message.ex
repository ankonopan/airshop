defmodule AirShop.BritishAirways.SOAP.Message do
  @doc ~S"""
  Builds a Map representing a Envelope request to British Airways

  ## Examples
    iex> xml_map = AirShop.BritishAirways.SOAP.Message.build("TXL", "LHR", "2020-01-01")
    iex> |> XmlBuilder.generate
    iex> String.match?(xml_map, ~r"TXL(\s*)?</AirportCode>") && String.match?(xml_map, ~r"LHR(\s*)?</AirportCode>")
    true
  """
  def build(departure, arrival, date) do
    {"s:Envelope", [{"xmlns:s", "http://schemas.xmlsoap.org/soap/envelope/"}],
     [
       {"s:Body", [{"xmlns", "http://www.iata.org/IATA/EDIST"}],
        [
          {"AirShoppingRQ", [{"Version", "3.0"}, {"xmlns", "http://www.iata.org/IATA/EDIST"}],
           [
             {"PointOfSale", [], [{"Location", [], [{"CountryCode", [], ["DE"]}]}]},
             {"Document", [], nil},
             {"Party", [],
              [
                {"Sender", [],
                 [
                   {"TravelAgencySender", [],
                    [
                      {"Name", [], ["test agent"]},
                      {"IATA_Number", [], ["00002004"]},
                      {"AgencyID", [], ["test agent"]}
                    ]}
                 ]}
              ]},
             {"Travelers", [],
              [
                {"Traveler", [],
                 [
                   {"AnonymousTraveler", [], [{"PTC", [{"Quantity", "1"}], ["ADT"]}]}
                 ]}
              ]},
             {"CoreQuery", [],
              [
                {"OriginDestinations", [],
                 [
                   {"OriginDestination", [],
                    [
                      {"Departure", [], [{"AirportCode", [], [departure]}, {"Date", [], [date]}]},
                      {"Arrival", [], [{"AirportCode", [], [arrival]}]}
                    ]}
                 ]}
              ]}
           ]}
        ]}
     ]}
  end
end
