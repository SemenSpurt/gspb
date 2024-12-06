# Feed

## Creating database tables
mix.bat phx.gen.context Routes Route routes route_id:integer agency_id:integer route_short_name:string route_long_name:string route_type:integer transport_type:integer circular:boolean urban:boolean night:boolean

mix.bat phx.gen.context Trips Trip trips route_id:integer service_id:integer trip_id:integer direction_id:boolean shape_id:string

mix.bat phx.gen.context Stops Stop stops stop_id:integer stop_code:integer stop_name:string stop_lat:float stop_lon:float location_type:integer wheelchair_boarding:integer transport_type:string 

mix.bat phx.gen.context Times Time times trip_id:integer  arrival_time:time departure_time:time stop_id:integer stop_sequence:integer shape_id:string shape_dist_traveled:float

mix.bat phx.gen.context Freqs Freq freqs trip_id:integer start_time:time end_time:time headway_secs:integer  exact_times:boolean

mix.bat phx.gen.context Shapes Shape shapes shape_id:string shape_pt_lat:float shape_pt_lon:float shape_pt_sequence:integer shape_dist_traveled:float

mix.bat phx.gen.context Week Days days service_id:integer monday:boolean tuesday:boolean wednesday:boolean thursday:boolean friday:boolean saturday:boolean sunday:boolean start_date:date end_date:date service_name:string

mix.bat phx.gen.context Dates Date dates service_id:integer date:date exception_type:integer


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
