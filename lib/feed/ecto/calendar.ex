defmodule Feed.Ecto.Calendar do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Ecto.Trips.Trip
  }


  defmodule Calendar do
    use Ecto.Schema
    import Ecto.Changeset

    schema "calendar" do
      field :start_date, :date
      field :end_date, :date
      field :monday, :boolean
      field :tuesday, :boolean
      field :wednesday, :boolean
      field :thursday, :boolean
      field :friday, :boolean
      field :saturday, :boolean
      field :sunday, :boolean
      field :name, :string

      has_many :trips, Trip,
        foreign_key: :service_id,
        references: :id

      timestamps(type: :utc_datetime)
    end

    @doc false
    def changeset(days, attrs) do
      days
      |> cast(attrs, [
        :id,
        :start_date,
        :end_date,
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
        :id,
        :start_date,
        :end_date,
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


  def list_days do
    Repo.all(Calendar)
  end


  def get_days!(id), do: Repo.get!(Calendar, id)


  def create_days(attrs \\ %{}) do
    %Calendar{}
    |> Calendar.changeset(attrs)
    |> Repo.insert()
  end


  def update_days(%Calendar{} = days, attrs) do
    days
    |> Calendar.changeset(attrs)
    |> Repo.update()
  end


  def delete_days(%Calendar{} = days) do
    Repo.delete(days)
  end


  def change_days(%Calendar{} = calendar, attrs \\ %{}) do
    Calendar.changeset(calendar, attrs)
  end


  def import_records(records \\ %{}) do
    Repo.insert_all(Calendar, records)
  end
end
