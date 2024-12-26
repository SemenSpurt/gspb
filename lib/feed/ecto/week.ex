defmodule Feed.Ecto.Week do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Ecto.Calendar.Calendar
  }


  defmodule Week do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:service_name, :string, autogenerate: false}
    schema "week" do
      field :monday, :boolean
      field :tuesday, :boolean
      field :wednesday, :boolean
      field :thursday, :boolean
      field :friday, :boolean
      field :saturday, :boolean
      field :sunday, :boolean


      has_many :calendar, Calendar,
        foreign_key: :name,
        references: :service_name

      timestamps(type: :utc_datetime)
    end

    @doc false
    def changeset(days, attrs) do
      days
      |> cast(attrs, [
        :service_name,
        :monday,
        :tuesday,
        :wednesday,
        :thursday,
        :friday,
        :saturday,
        :sunday
        ])
      |> validate_required([
        :service_name,
        :monday,
        :tuesday,
        :wednesday,
        :thursday,
        :friday,
        :saturday,
        :sunday
        ])
    end
  end


  def list_days do
    Repo.all(Week)
  end


  def get_week!(id), do: Repo.get!(Week, id)


  def create_week(attrs \\ %{}) do
    %Week{}
    |> Week.changeset(attrs)
    |> Repo.insert()
  end


  def update_week(%Week{} = week, attrs) do
    week
    |> Week.changeset(attrs)
    |> Repo.update()
  end


  def delete_week(%Week{} = week) do
    Repo.delete(week)
  end


  def change_week(%Week{} = week, attrs \\ %{}) do
    Week.changeset(week, attrs)
  end


  def import_records(records \\ %{}) do
    Repo.insert_all(Week, records)
  end
end
