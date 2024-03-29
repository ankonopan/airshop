# AirShop

## **Air lines Ticket Aggregator**

Search and aggregates data from two airline fares service providers to find the cheapest flight between two airport destinations.

## Design and Components

This application is designed as an umbrella project to divide the solution into two individual services: The Web API Service and the Air Shop Service. Each of them are located on individual apps in this umbrella project.

**The Web API Service:** Provides a Cowboy-Plug small frontend to the world where you can reach the flight search and get the cheapest flight by calling:

`/cheapestOffer?origin=TXL&destination=LHR&departureDate=2020-01-01`

**The Air Shop Service:** Provides a HTTP client serviced application. This application is logically divided into 3 applications:

*AirShop Service:* Is a simple GenServer that works as interface and aggregator to the Web API providing a `handle_call` method to execute the flight aggregation.

*Air France KLM Service:* Is a pooled service that provide communication with the Air France KLM SOPA API and parsing/processing results.

*British Airways Service:* Is a pooled service that provide communication with the British Airways SOPA API and parsing/processing results.

The current design is logically divided as follow:

![Design](docs/app_design_0.1.0.png)

## Execution:

In order to run the application you will need to export the API keys before into your environment:

```
export AIR_FRANCE_API_KEY="xyz..."
export BRITISH_AIRWAYS_API_KEY="xyz..."

```

Then run the application as needed from the console:

```
mix run --no-halt
```

## Testing

Run `mix test` from the umbrella folder.

Only simple test are developed as the full SOAP API is not covered and some of the cases may or will result in complex abstraction after covering all the cases.


