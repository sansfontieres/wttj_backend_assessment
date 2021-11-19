defmodule JobsWorldwide.CSVParser do
  @moduledoc "CSV parser for `jobs_worldwide`."

  alias NimbleCSV.RFC4180, as: CSV

  @spec parse_csv(String.t()) :: function
  defp parse_csv(file) do
    file
    |> File.stream!()
    |> CSV.parse_stream()
  end

  @doc """
  This function parses the profession CSV and creates an Elixir map
  linking for each id an atom with the profession category.

  ## Example
      iex> JobsWorldwide.CSVParser.map_professions
      %{
       "17" => :Tech,
       "24" => :Admin,
       "38" => :Conseil,
       ...
      }
  """
  @spec map_professions(function) :: map
  def map_professions(professions_csv) do
    list =
      professions_csv
      |> Stream.map(fn [id, _, category] ->
        category = String.to_atom(category)

        {category, id}
      end)

    for {k, v} <- list, into: %{}, do: {v, k}
  end

  @spec get_category(String.t(), function) :: atom
  defp get_category(id, professions_csv) do
    map_professions(professions_csv)
    |> Enum.find(fn {k, _} -> k == id end)
    |> elem(1)
  end

  @doc """
  Parses the jobs CSV and creates a list containing the continent and the job
  offer’s category in atoms.

  ## Example
      iex> JobsWorldwide.CsvParser.map_jobs
      [
        Créa:  :Europe,
        Tech:  :"Amérique du Nord",
        Business: :Europe,
        ...
      ]

  Safety measures were taken if some fields were missing.
  """
  @spec map_jobs(function, function) :: list
  def map_jobs(jobs_csv, professions_csv) do
    jobs_csv
    |> Stream.map(fn
      [id, _, _, latitude, longitude] ->
        category =
          try do
            get_category(id, professions_csv)
          catch
            _, _ -> :"N/A"
          end

        continent =
          try do
            JobsWorldwide.ContinentsMap.get_continent(
              String.to_float(latitude),
              String.to_float(longitude)
            )
          catch
            _, _ -> :"N/A"
          end

        {continent, category}
    end)
    |> Enum.to_list()
  end

  @doc "This is the entry point to this module."
  @spec get_offers_list(String.t(), String.t()) :: list
  def get_offers_list(jobs_csv, professions_csv) do
    jobs_csv = parse_csv(jobs_csv)
    professions_csv = parse_csv(professions_csv)
    map_jobs(jobs_csv, professions_csv)
  end
end
