defmodule JobsWorldwide.CSVParser do
  @moduledoc "CSV parser for `jobs_worldwide`."

  alias NimbleCSV.RFC4180, as: CSV

  @doc "Returns a parsed CSV as a stream from a path"
  @spec parse_csv(String.t()) :: function
  def parse_csv(file) do
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

  @spec upcase_atom(:atom) :: :atom
  defp upcase_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.upcase()
    |> String.to_atom()
  end

  @spec downcase_atom(:atom) :: :atom
  defp downcase_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.downcase()
    |> String.to_atom()
  end

  @doc """
  Parses the jobs CSV and creates a list containing the continent and the job
  offer’s category in atoms.

  ## Example
      iex> JobsWorldwide.CsvParser.map_jobs(jobs_csv, professions_csv)
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
            |> upcase_atom
          catch
            _, _ -> :"N/A"
          end

        continent =
          try do
            JobsWorldwide.ContinentsMap.get_continent(
              String.to_float(latitude),
              String.to_float(longitude)
            )
            |> upcase_atom
          catch
            _, _ -> :"N/A"
          end

        {continent, category}
    end)
    |> Enum.to_list()
  end

  @doc """
  Behaves like `map_jobs` but returns a complete list with the contract type,
  the job description.
  """
  @spec map_jobs_full(function, function) :: list
  def map_jobs_full(jobs_csv, professions_csv) do
    list =
      jobs_csv
      |> Stream.map(fn
        [id, contract, name, latitude, longitude] ->
          category =
            try do
              get_category(id, professions_csv)
              |> downcase_atom
            catch
              _, _ -> :"N/A"
            end

          continent =
            try do
              JobsWorldwide.ContinentsMap.get_continent(
                String.to_float(latitude),
                String.to_float(longitude)
              )
              |> downcase_atom
            catch
              _, _ -> :"N/A"
            end

          contract = contract |> String.downcase() |> String.to_atom()

          {continent, contract, name, category}
      end)
      |> Enum.to_list()

    for {a, b, c, d} <- list,
        do: Map.new([{:continent, a}, {:contract, b}, {:name, c}, {:category, d}])
  end

  @doc "This is the entry point to this module. Only used for the CLI"
  @spec get_offers_list(String.t(), String.t()) :: list
  def get_offers_list(jobs_csv, professions_csv) do
    jobs_csv = parse_csv(jobs_csv)
    professions_csv = parse_csv(professions_csv)
    map_jobs(jobs_csv, professions_csv)
  end
end
