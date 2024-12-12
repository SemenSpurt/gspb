# Feed

## Load database

mix run utils/seed.ex

## List routes
{
  listRoutes {
    agencyId
    circular
    night
    routeId
    routeLongName
    routeShortName
    routeType
    transportType
    urban
  }
}

## List stops
{
  listStops {
    locationType
    stopCode
    stopId
    stopLat
    stopLon
    stopName
    transportType
    wheelchairBoarding
  }
}

## Get route by id (e.g. id=223)
{
  getRoute(routeId:223) {
    agencyId
    circular
    night
    routeId
    routeLongName
    routeShortName
    routeType
    transportType
    urban
  }
}

## List trips by route and date (e.g. route_id=223, date="2010-04-29")
{
  routeTrips(routeId: 223, date: "2024-04-29") {
    routeId
    trip_id
    service_id
   
  }
}

## List stops and trajectories for specific trip (e.g. trip_id=65019644)

{
  tripStops(tripId: 65019644) {
    routeId
    serviceId
    tripId
    times {
      arrivalTime
      shapeId
      stopId
      stopSequence
      stop {
        stopName
      }
      shapes {
        shapeId
        shapePtLat
        shapePtLon
        shapePtSequence
      }
    }
  }
}



To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
