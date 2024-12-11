defmodule Feed.Time.Dates do

  import Ecto.Query, warn: false
  alias Feed.Repo

  alias Date, as: Datedate


  defmodule Date do

    use Ecto.Schema
    import Ecto.Changeset
    alias Feed.Route.Trips.Trip

    schema "dates" do
      field :service_id,     :integer
      field :date,           :date
      field :exception_type, :integer

      has_many :trips, Trip, foreign_key: :service_id, references: :service_id

      timestamps(type: :utc_datetime)
    end

    @doc false
    def changeset(date, attrs) do
      date
      |> cast(attrs, [:service_id, :date, :exception_type])
      |> validate_required([:service_id, :date, :exception_type])
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


  def import(records \\ %{}) do

    Date
    |> Repo.insert_all(
      Enum.map(records, fn [service_id, date, exception_type] ->
        %{

          :date => Datedate.from_iso8601!(
            Enum.at(
              (for <<
              y::binary-size(4),
              m::binary-size(2),
              d::binary-size(2) <- date
              >>, do: "#{y}-#{m}-#{d}"), 0
            )
          ),

          :exception_type  => String.to_integer(exception_type),
          :service_id      => String.to_integer(service_id),

          :inserted_at     => DateTime.utc_now(:second),
          :updated_at      => DateTime.utc_now(:second)
        }
      end))
  end
end
