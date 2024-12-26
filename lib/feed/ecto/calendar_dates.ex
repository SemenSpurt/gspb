defmodule Feed.Ecto.CalendarDates do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Ecto.Trips.Trip
  }

  defmodule Date do
    use Ecto.Schema
    import Ecto.Changeset

    schema "calendar_dates" do
      field :service_id, :integer
      field :date,      :date
      field :exception, :integer

      has_many :trips, Trip,
        foreign_key: :service_id,
        references: :service_id

      timestamps(type: :utc_datetime)
    end

    @doc false
    def changeset(date, attrs) do
      date
      |> cast(attrs, [
        :service_id,
        :date,
        :exception
      ])
      |> validate_required([
        :service_id,
        :date,
        :exception
      ])
    end
  end


  def list_dates do
    Repo.all(Date)
  end


  def get_date!(id), do: Repo.get!(Date, id)


  def create_date(attrs \\ %{}) do
    %Date{}
    |> Date.changeset(attrs)
    |> Repo.insert()
  end


  def update_date(%Date{} = date, attrs) do
    date
    |> Date.changeset(attrs)
    |> Repo.update()
  end


  def delete_date(%Date{} = date) do
    Repo.delete(date)
  end


  def change_date(%Date{} = date, attrs \\ %{}) do
    Date.changeset(date, attrs)
  end


  def import_records(records \\ %{}) do
    Repo.insert_all(Date, records)
  end
end
