defmodule FeedWeb.Gql.Schema do
  use Absinthe.Schema

  import_types(FeedWeb.Types.{
    Route,
    Stop
  })

  query do
    import_fields :stop_queries
    import_fields :route_queries
  end
end
