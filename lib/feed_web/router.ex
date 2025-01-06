defmodule FeedWeb.Router do
  use FeedWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api" do
    pipe_through :api

    # forward "/graphiql", Absinthe.Plug.GraphiQL,
    #   schema: FeedWeb.Schema,
    #   interface: :simple,
    #   context: %{pubsub: FeedWeb.Endpoint}

    forward "/graphql/editor", Absinthe.Plug.GraphiQL,
      # before_send: {__MODULE__, :before_send},
      # interface: :simple,
      schema: FeedWeb.Gql.Schema

    # context: %{pubsub: FeedWeb.Endpoint}

    forward "/graphql", Absinthe.Plug,
      # before_send: {__MODULE__, :before_send},
      # interface: :simple,
      schema: FeedWeb.Gql.Schema

    # context: %{pubsub: FeedWeb.Endpoint}
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:feed, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: FeedWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
