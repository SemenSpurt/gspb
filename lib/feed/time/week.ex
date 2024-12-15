defmodule Feed.Time.Week do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Route.Trips.Trip
  }


  defmodule Days do
    use Ecto.Schema
    import Ecto.Changeset

    schema "days" do
      field :service_id, :integer
      field :monday, :boolean
      field :tuesday, :boolean
      field :wednesday, :boolean
      field :thursday, :boolean
      field :friday, :boolean
      field :saturday, :boolean
      field :sunday, :boolean
      field :start_date, :date
      field :end_date, :date
      field :service_name, :string

      has_many :trips, Trip,
        foreign_key: :service_id,
        references: :service_id

      timestamps(type: :utc_datetime)
    end

    @doc false
    def changeset(days, attrs) do
      days
      |> cast(attrs, [
        :service_id,
        :monday,
        :tuesday,
        :wednesday,
        :thursday,
        :friday,
        :saturday,
        :sunday,
        :start_date,
        :end_date,
        :service_name
        ])
      |> validate_required([
        :service_id,
        :monday,
        :tuesday,
        :wednesday,
        :thursday,
        :friday,
        :saturday,
        :sunday,
        :start_date,
        :end_date,
        :service_name
        ])
    end
  end


  def list_days do
    Repo.all(Days)
  end


  def get_days!(id), do: Repo.get!(Days, id)


  def create_days(attrs \\ %{}) do
    %Days{}
    |> Days.changeset(attrs)
    |> Repo.insert()
  end


  def update_days(%Days{} = days, attrs) do
    days
    |> Days.changeset(attrs)
    |> Repo.update()
  end


  def delete_days(%Days{} = days) do
    Repo.delete(days)
  end


  def change_days(%Days{} = days, attrs \\ %{}) do
    Days.changeset(days, attrs)
  end


  def import(records \\ %{}) do
    Days
    |> Repo.insert_all(
      Enum.map(records, fn [
        service_id,
        service_name,
        monday,
        tuesday,
        wednesday,
        thursday,
        friday,
        saturday,
        sunday,
        start_date,
        end_date
      ] ->
      %{
        :service_id   => String.to_integer(service_id),
        :service_name => service_name,
        :monday       => monday == "1",
        :tuesday      => tuesday == "1",
        :wednesday    => wednesday == "1",
        :thursday     => thursday == "1",
        :friday       => friday == "1",
        :saturday     => saturday == "1",
        :sunday       => sunday == "1",

        :start_date   => Date.from_iso8601!(
          Enum.at(
            (for <<
            y::binary-size(4),
            m::binary-size(2),
            d::binary-size(2) <- start_date
            >>, do: "#{y}-#{m}-#{d}"), 0
          )
        ),

        :end_date     => Date.from_iso8601!(
          Enum.at(
            (for <<
            y::binary-size(4),
            m::binary-size(2),
            d::binary-size(2) <- end_date
            >>, do: "#{y}-#{m}-#{d}"), 0
          )
        ),

        :inserted_at  => DateTime.utc_now(:second),
        :updated_at   => DateTime.utc_now(:second)
      }
      end)
    )
  end
end
