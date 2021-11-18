defmodule JobsWorldwide do
  @moduledoc """
  This application returns a table of job offers per continents.
  """

  alias JobsWorldwide.CSVParser

  @doc """
  The entry function of the CLI.  
  It orchestrates every functions to output the job offers table.
  """
  def main(_) do
    job_offers = CSVParser.map_jobs("data/technical-test-jobs.csv")

    IO.inspect(Enum.to_list(job_offers), limit: :infinity)
  end
end
