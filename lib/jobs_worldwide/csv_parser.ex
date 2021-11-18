defmodule JobsWorldwide.CsvParser do
  @moduledoc "CSV parser for `jobs_worldwide`."

  @filepath "data/technical-test-"
  @professions_csv @filepath <> "professions.csv"
  @jobs_csv @filepath <> "jobs.csv"

  defp parse_csv(file) do
    file
    |> File.stream!()
    |> Stream.drop(1)
    |> Stream.map(fn line ->
      String.trim(line) |> String.split(",")
    end) 
  end

  @doc """
    This function parses the profession CSV and creates an Elixir map
    containing an integer for the id, and an atom for the profession.

    Example:
    iex> JobsWorldwide.CsvParser.map_professions
    %{
      33 => :Retail,
      12 => :Tech,
      23 => :Admin,
      15 => :Tech,
      # snip
    }
  """
  def map_professions do
    professions = parse_csv(@professions_csv)

    professions
    |> Enum.into(%{}, fn [id, _, profession] ->
      {String.to_integer(id), String.to_atom(profession)}
    end)
  end

  def map_jobs do
    jobs = parse_csv(@jobs_csv)

    jobs
    |> Enum.into(%{}, fn [id, _, _, latitude, longitude] ->
      {String.to_integer(id), [latitude, longitude]}
    end)
  end

  def test do
    IO.inspect(map_professions())
  end
end
