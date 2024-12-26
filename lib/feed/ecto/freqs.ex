defmodule Feed.Ecto.Freqs do
  import Ecto.Query, warn: false

  alias Feed.{
    Repo,
    Ecto.Trips.Trip
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

      timestamps(type: :utc_datetime)
    end

    def changeset(freq, attrs) do
      freq
      |> cast(attrs, [
        :trip_id,
        :start_time,
        :end_time,
        :headway_secs
      ])
      |> validate_required([
        :trip_id,
        :start_time,
        :end_time,
        :headway_secs
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


  def import_records(records \\ %{}) do
    Repo.insert_all(Freq, records)
  end
end
