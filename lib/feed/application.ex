defmodule Feed.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Toolkit
  NimbleCSV.define(FileParser, separator: ",", escape: "\"")

  @impl true
  def start(_type, _args) do
    children = [
      FeedWeb.Telemetry,
      Feed.Repo,
      {DNSCluster, query: Application.get_env(:feed, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Feed.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Feed.Finch},
      # Start a worker by calling: Feed.Worker.start_link(arg)
      # {Feed.Worker, arg},
      # Start to serve requests, typically the last entry
      FeedWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Feed.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FeedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
