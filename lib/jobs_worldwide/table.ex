defmodule JobsWorldwide.Table do
  @moduledoc "Creates a table out of job listing"

  alias JobsWorldwide.CSVParser
  alias TableRex.Table

  @doc """
  Returns a table from a list of jobs offers.
  - Y axis cells are categories of jobs.
  - X axis cells are continents of offices.

  Example:
      iex> Jobs.Worldwide.Table.create_table(jobs_offers)

  """
  @spec create_table(map) :: String.t()
  def create_table(job_offers) do
    frequencies = Enum.frequencies(job_offers)
    continents_totals = job_offers |> Enum.frequencies_by(&elem(&1, 0))
    categories_totals = job_offers |> Enum.frequencies_by(&elem(&1, 1))

    total = length(job_offers)
    IO.inspect(frequencies)
    IO.inspect(continents_totals)
    IO.inspect(categories_totals)
    IO.inspect(total)
  end
end
