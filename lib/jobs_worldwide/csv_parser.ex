defmodule JobsWorldwide.CSVParser do
  @moduledoc "CSV parser for `jobs_worldwide`."

  alias NimbleCSV.RFC4180, as: CSV

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
  def map_professions do
    list =
      parse_csv("data/technical-test-professions.csv")
      |> Stream.map(fn [id, _, category] ->
        category = String.to_atom(category)

        {category, id}
      end)

    for {k, v} <- list, into: %{}, do: {v, k}
  end

  defp get_category(id) do
    map_professions()
    |> Enum.find(fn {k, _} -> k == id end)
    |> elem(1)
  end

  @doc """
  Parses the jobs CSV and creates a list of maps containing the continent and
  the job offer category in atoms.

  ## Example
      iex> JobsWorldwide.CsvParser.map_jobs |> Enum.to_list
      [
        %{category: :Créa, location: :Europe},
        %{category: :Tech, location: :"Amérique du Nord"},
        %{category: :Business, location: :Europe},
        ...
      ]

  Safety measures were taken if some fields were missing.
  """
  def map_jobs(file) do
    parse_csv(file)
    |> Stream.map(fn
      [id, _, _, latitude, longitude] ->
        category =
          try do
            get_category(id)
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

        %{location: continent, category: category}
    end)
  end
end
