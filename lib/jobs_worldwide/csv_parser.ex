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
end
