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
    jobs_csv = "data/technical-test-jobs.csv"
    professions_csv = "data/technical-test-professions.csv"

    job_offers = CSVParser.get_offers_list(jobs_csv, professions_csv)

    Table.create_table(job_offers)
  end
end
