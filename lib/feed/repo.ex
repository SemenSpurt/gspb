defmodule Feed.Repo do
  use Ecto.Repo,
    otp_app: :feed,
    adapter: Ecto.Adapters.Postgres
end
