defmodule Feed.Ecto.Calendar do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Ecto.Trips.Trip
  }

  defmodule Calendar do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:service_id, :integer, autogenerate: false}
    schema "calendar" do
      field :start_date, :date
      field :end_date, :date
      field :name, :string

      has_one :week, Week,
        foreign_key: :name,
        references: :name

      has_many :trips, Trip,
        foreign_key: :service_id,
        references: :service_id
    end

    def changeset(calendar, attrs) do
      calendar
      |> cast(attrs, [
        :service_id,
        :start_date,
        :end_date,
        :name
      ])
      |> validate_required([
        :service_id,
        :start_date,
        :end_date,
        :name
      ])
    end
  end

  def list_calendar do
    Repo.all(Calendar)
  end

  defmodule Week do
    use Ecto.Schema
    import Ecto.Changeset

    # @primary_key {:name, :string, autogenerate: false}
    schema "week" do
      field :name, :string, primary_key: true
      field :monday, :boolean
      field :tuesday, :boolean
      field :wednesday, :boolean
      field :thursday, :boolean
      field :friday, :boolean
      field :saturday, :boolean
      field :sunday, :boolean

      has_many :calendar, Calendar,
        foreign_key: :name,
        references: :name
    end

    def changeset(week, attrs) do
      week
      |> cast(attrs, [
        :monday,
        :tuesday,
        :wednesday,
        :thursday,
        :friday,
        :saturday,
        :sunday,
        :name
      ])
      |> validate_required([
        :monday,
        :tuesday,
        :wednesday,
        :thursday,
        :friday,
        :saturday,
        :sunday,
        :name
      ])
    end
  end

  def list_week do
    Repo.all(Week)
  end
end
