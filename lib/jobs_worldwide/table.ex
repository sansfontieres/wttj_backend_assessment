defmodule JobsWorldwide.Table do
  @moduledoc "Creates a table out of job listing"

  # This function formats a list of rows to work with TableRex
  @spec rowify(map, map, map) :: list
  defp rowify(continents_totals, categories_totals, frequencies) do
    totals_row = Map.values(categories_totals)
    total_offers = Enum.sum(totals_row)
    totals_row = ["TOTAL", total_offers | totals_row]
    row_list = Map.keys(categories_totals)
    header_list = Map.keys(continents_totals)

    rows =
      [] ++
        for x <- header_list do
          row = [x]

          continent_total = continents_totals[x]

          total =
            for z <- row_list do
              total = frequencies[{x, z}]

              case total do
                nil -> 0
                _ -> total
              end
            end

          row = row ++ [continent_total] ++ total
          row
        end

    rows = [totals_row | rows]
    rows
  end

  @doc """
  Returns a table from a list of jobs offers.
  - Y axis cells are categories of jobs.
  - X axis cells are continents of offices.
  - The first row and columns are the totals of offers

  Example:
      iex> Jobs.Worldwide.Table.create_table(jobs_offers)

  """
  @spec create_table(list) :: :atom
  def create_table(job_offers) do
    frequencies = Enum.frequencies(job_offers)
    continents_totals = job_offers |> Enum.frequencies_by(&elem(&1, 0))
    categories_totals = job_offers |> Enum.frequencies_by(&elem(&1, 1))

    # Formatting the totals to fit into TableRex’ needs
    header = ["", "TOTAL" | Map.keys(categories_totals)]
    rows = rowify(continents_totals, categories_totals, frequencies)

    TableRex.quick_render!(rows, header)
    |> IO.puts()
  end
end
