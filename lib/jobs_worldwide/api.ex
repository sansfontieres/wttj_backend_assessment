defmodule JobsWorldwide.API do
  alias JobsWorldwide.CSVParser

  @jobs_csv CSVParser.parse_csv("data/technical-test-jobs.csv")

  @professions_csv CSVParser.parse_csv("data/technical-test-professions.csv")

  @offers CSVParser.map_jobs_full(@jobs_csv, @professions_csv)

  @spec normalize_to_atom(String.t()) :: :atom
  defp normalize_to_atom(query) do
    query
    |> String.downcase()
    |> String.to_atom()
  end

  @doc """
  Returns a list of offers matching a query. The query itself is a map created
  from `URL.decode_query/1`.

  Queries may only dig through continents, contract types and the profession
  category in a job offer. Any other kind of key return the atom
  `:malformed_query`, unless there’s at least one honored key.

  ## Example
      iex> JobsWorldwide.API.query_filter(%{"continent" => "Océanie"})
      [
        %{
          category: :retail,
          continent: :océanie,
          contract: :full_time,
          name: "[TAG Heuer Australia] Boutique Manager - Melbourne"
        }
      ]
  """
  @spec query_filter(map) :: list
  def query_filter(query) do
    query = for {k, v} <- query, into: %{}, do: {k, normalize_to_atom(v)}

    case query do
      %{"continent" => continent, "contract" => contract, "category" => category} ->
        Enum.filter(@offers, fn x ->
          x.continent == continent and x.contract == contract and x.category == category
        end)

      %{"contract" => contract, "category" => category} ->
        Enum.filter(@offers, fn x -> x.contract == contract and x.category == category end)

      %{"continent" => continent, "category" => category} ->
        Enum.filter(@offers, fn x -> x.continent == continent and x.category == category end)

      %{"continent" => continent, "contract" => contract} ->
        Enum.filter(@offers, fn x -> x.continent == continent and x.contract == contract end)

      %{"continent" => continent} ->
        Enum.filter(@offers, fn x -> x.continent == continent end)

      %{"contract" => contract} ->
        Enum.filter(@offers, fn x -> x.contract == contract end)

      %{"category" => category} ->
        Enum.filter(@offers, fn x -> x.category == category end)

      _ ->
        :malformed_query
    end
  end

  @doc "Returns a list of every offers"
  @spec get_offers :: list
  def get_offers do
    @offers
  end
end
