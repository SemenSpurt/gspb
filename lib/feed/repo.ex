defmodule Feed.Repo do
  use Ecto.Repo,
    otp_app: :feed,
    adapter: Ecto.Adapters.Postgres

  @impl true
  def default_options(_operation) do
    [
      prefix: "2025-02-02" #Timex.today("GMT+3") |> to_string
    ]
  end
end
