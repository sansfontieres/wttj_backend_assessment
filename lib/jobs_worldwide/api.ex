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
  Returns a JSON in the case where we have to transmit in this format instead
  of an ETF binary.
  """
  @spec json_serialize(list) :: String.t()
  def json_serialize(body) do
    body =
      try do
        for {a, b, c, d} <- body,
            do: Map.new([{"continent", a}, {"contract", b}, {"name", c}, {"category", d}])
      catch
        _, _ -> body
      end

    Jason.encode!(body)
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
        {:océanie, :full_time, "[TAG Heuer Australia] Boutique Manager - Melbourne",
         :retail}
      ]
  """
  @spec query_filter(map) :: list
  def query_filter(query) do
    query = for {k, v} <- query, into: %{}, do: {k, normalize_to_atom(v)}

    case query do
      %{"continent" => continent, "contract" => contract, "category" => category} ->
        Enum.filter(@offers, fn x -> match?({^continent, ^contract, _, ^category}, x) end)

      %{"contract" => contract, "category" => category} ->
        Enum.filter(@offers, fn x -> match?({_, ^contract, _, ^category}, x) end)

      %{"continent" => continent, "category" => category} ->
        Enum.filter(@offers, fn x -> match?({^continent, _, _, ^category}, x) end)

      %{"continent" => continent, "contract" => contract} ->
        Enum.filter(@offers, fn x -> match?({^continent, ^contract, _, _}, x) end)

      %{"continent" => continent} ->
        Enum.filter(@offers, fn x -> match?({^continent, _, _, _}, x) end)

      %{"contract" => contract} ->
        Enum.filter(@offers, fn x -> match?({_, ^contract, _, _}, x) end)

      %{"category" => category} ->
        Enum.filter(@offers, fn x -> match?({_, _, _, ^category}, x) end)

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
