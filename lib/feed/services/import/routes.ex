defmodule Feed.Services.Import.Routes do
  # OK
  # """
  #   route_id:           integer
  #   agency_id:          string  : drop
  #   route_short_name:   string
  #   route_long_name:    string
  #   route_type:         integer : drop
  #   transport_type:     string
  #   circular:           boolean
  #   urban:              boolean
  #   night:              boolean : drop
  # """

  alias Feed.{
    Repo,
    Ecto.Routes.Route,
    Services.Research.Routes
  }

  def import_records() do
    Routes.records()
    |> Stream.chunk_every(1000)
    |> Enum.each(&Repo.insert_all(Route, &1))
  end
end
