defmodule JobsWorldwide do
  @moduledoc """
  This application returns a table of job offers per continents.
  """

  alias JobsWorldwide.CSVParser
  alias JobsWorldwide.Table

  @doc """
  The entry function of the CLI.  
  It orchestrates every functions to output the job offers table.
  """
  def main(_) do
    job_offers = CSVParser.map_jobs()

    Table.create_table(job_offers)
  end
end
