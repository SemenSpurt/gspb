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
    Ecto.Routes.Route
  }

  @file_path "C:/Users/SamJa/Desktop/Notebooks/feed/routes.txt"

  def import_records(file_path \\ @file_path) do
    file_path
    |> File.stream!()
    |> FileParser.parse_stream()
    |> Enum.map(fn [id, _, short_name, long_name, _, transport, circular, urban, _] ->
      %{
        id: String.to_integer(id),
        short_name: String.trim(short_name),
        long_name: String.trim(long_name),
        transport: String.trim(transport),
        circular: String.to_integer(circular) == 1,
        urban: String.to_integer(urban) == 1
      }
    end)
    |> Stream.chunk_every(1000)
    |> Enum.each(&Repo.insert_all(Route, &1))
  end
end
