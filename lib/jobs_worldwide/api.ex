defmodule JobsWorldwide.API do
  alias JobsWorldwide.CSVParser

  @jobs_csv CSVParser.parse_csv("data/technical-test-jobs.csv")

  @professions_csv CSVParser.parse_csv("data/technical-test-professions.csv")

  @offers CSVParser.map_jobs_full(@jobs_csv, @professions_csv)

  def find_by_continent(continent) do
    query = String.to_atom(continent)
    Enum.filter(@offers, fn x -> match?({^query, _, _, _}, x) end)
  end

  def find_by_contract(contract) do
    query = String.to_atom(contract)
    Enum.filter(@offers, fn x -> match?({_, ^query, _, _}, x) end)
  end

  def find_by_category(category) do
    query = String.to_atom(category)
    Enum.filter(@offers, fn x -> match?({_, _, _, ^query}, x) end)
  end

  defp normalize_to_atom(query) do
    query
    |> String.downcase()
    |> String.to_atom()
  end

  def get_offers do
    @offers
  end
end
