defmodule AirShop.AirFrance.Request do
  @doc ~S"""
  Builds a Map representing a Envelope request to Air France KLM

  ## Examples
    iex> xml_map = AirShop.AirFrance.Request.build("TXL", "LHR", "2020-01-01")
    iex> |> XmlBuilder.generate
    iex> String.match?(xml_map, ~r"TXL(\s*)?</AirportCode>") && String.match?(xml_map, ~r"LHR(\s*)?</AirportCode>")
    true
  """
  def build(departure, arrival, date) do
    {"soapenv:Envelope", [{"xmlns:soapenv", "http://schemas.xmlsoap.org/soap/envelope/"}],
     [
       {"soapenv:Header", [], nil},
       {"soapenv:Body", [{"xmlns", "http://www.iata.org/IATA/EDIST/2017.1"}],
        [
          {"AirShoppingRQ", [{"Version", "17.1"}],
           [
             {"Document", [], nil},
             {"Party", [],
              [
                {"Sender", [],
                 [
                   {"TravelAgencySender", [],
                    [
                      {"Name", [], ["Test"]},
                      {"PseudoCity", [], ["PARMM211L"]},
                      {"IATA_Number", [], ["12345675"]},
                      {"AgencyID", [], ["id"]}
                    ]}
                 ]},
                {"Recipient", [], [{"ORA_Recipient", [], [{"AirlineID", [], ["AF"]}]}]}
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
              ]},
             {"Preference", [],
              [{"CabinPreferences", [], [{"CabinType", [], [{"Code", [], ["1"]}]}]}]},
             {"DataLists", [],
              [{"PassengerList", [], [{"Passenger", [], [{"PTC", [], ["ADT"]}]}]}]}
           ]}
        ]}
     ]}
  end
end
