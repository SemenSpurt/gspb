defmodule Feed.Time.Freqs do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Route.Trips.Trip
  }


  defmodule Freq do
    use Ecto.Schema
    import Ecto.Changeset

    schema "freqs" do
      belongs_to :trips, Trip,
        foreign_key: :trip_id,
        references: :trip_id

      field :start_time, :time
      field :end_time, :time
      field :headway_secs, :integer
      field :exact_times, :boolean

      timestamps(type: :utc_datetime)
    end

    def changeset(freq, attrs) do
      freq
      |> cast(attrs, [
        :trip_id,
        :start_time,
        :end_time,
        :headway_secs,
        :exact_times
      ])
      |> validate_required([
        :trip_id,
        :start_time,
        :end_time,
        :headway_secs,
        :exact_times
      ])
    end
end


  def list_freqs do
    Repo.all(Freq)
  end

  def get_freq!(id), do: Repo.get!(Freq, id)


  def create_freq(attrs \\ %{}) do
    %Freq{}
    |> Freq.changeset(attrs)
    |> Repo.insert()
  end


  def update_freq(%Freq{} = freq, attrs) do
    freq
    |> Freq.changeset(attrs)
    |> Repo.update()
  end


  def delete_freq(%Freq{} = freq) do
    Repo.delete(freq)
  end


  def change_freq(%Freq{} = freq, attrs \\ %{}) do
    Freq.changeset(freq, attrs)
  end


  def import(records \\ %{}) do

    Freq
    |> Repo.insert_all(
      Enum.map(records, fn [
        trip_id,
        start_time,
        end_time,
        headway_secs,
        exact_times
      ] ->
      %{
        :trip_id      => String.to_integer(trip_id),
        :end_time     => Time.from_iso8601!(start_time),
        :start_time   => Time.from_iso8601!(end_time),
        :headway_secs => String.to_integer(headway_secs),
        :exact_times  => exact_times == "1",

        :inserted_at  => DateTime.utc_now(:second),
        :updated_at   => DateTime.utc_now(:second)
      }
      end)
    )
  end
end
