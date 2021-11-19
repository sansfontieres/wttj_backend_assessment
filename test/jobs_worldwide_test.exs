defmodule JobsWorldwideTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest JobsWorldwide

  alias NimbleCSV.RFC4180, as: CSV

  test "Gets :Afrique from Pointe-Noire’s (Congo, Africa) coordinates" do
    assert JobsWorldwide.ContinentsMap.get_continent(-4.769162, 11.866362) == :Afrique
  end

  test "Gets :Asie from Taipei’s (Taiwan, Asia) coordinates" do
    assert JobsWorldwide.ContinentsMap.get_continent(25.105497, 121.597366) == :Asie
  end

  test "Gets :Europe from Moscow’s (Russia, Europe) coordinates" do
    assert JobsWorldwide.ContinentsMap.get_continent(55.751244, 37.618423) == :Europe
  end

  test "Gets :\"Amérique du Nord\" from Montreal’s (Canada, North America) coordinates" do
    assert JobsWorldwide.ContinentsMap.get_continent(45.5016889, -73.567256) ==
             :"Amérique du Nord"
  end

  test "Gets :\"Amérique du Sud\" from Bogota’s (Colombia, South America) coordinates" do
    assert JobsWorldwide.ContinentsMap.get_continent(4.598056, -74.075833) == :"Amérique du Sud"
  end

  test "Gets :Océanie from Hobart’s (Australia, Oceania) coordinates" do
    assert JobsWorldwide.ContinentsMap.get_continent(-42.88583, 147.33139) == :Océanie
  end

  test "Gets :Antartique from Cuverville Island’s (Antartica) coordinates" do
    assert JobsWorldwide.ContinentsMap.get_continent(-64.683333, -62.633333) == :Antartique
  end

  test "Gets :\"N/A\" froma a random place in the Pacific Ocean" do
    assert JobsWorldwide.ContinentsMap.get_continent(30, 165) == :"N/A"
  end

  # We added a slight abstraction on those to test the filesystem IO
  # Since those functions are critical, we should at least test them for the
  # exercise.
  defp parse_csv(file) do
    file
    |> File.stream!()
    |> CSV.parse_stream()
  end

  test "Professions CSV parsing is correctly handled" do
    professions_csv = parse_csv("test/fixtures/professions_test.csv")

    list = %{
      "28" => :Créa,
      "14" => :Tech,
      "1" => :Business
    }

    assert JobsWorldwide.CSVParser.map_professions(professions_csv) == list
  end

  test "Jobs CSV parsing is correctly handled" do
    jobs_csv = parse_csv("test/fixtures/jobs_test.csv")
    professions_csv = parse_csv("test/fixtures/professions_test.csv")

    list = [
      Europe: :Créa,
      "Amérique du Nord": :Tech,
      Europe: :Business,
      "N/A": :"N/A"
    ]

    assert JobsWorldwide.CSVParser.map_jobs(jobs_csv, professions_csv) == list
  end

  test "Offers list gets correctly processed into a table" do
    list = [
      Europe: :"Marketing / Comm'",
      Europe: :"Marketing / Comm'",
      Europe: :Business,
      Europe: :"Marketing / Comm'",
      Europe: :Conseil,
      Europe: :Business,
      "Amérique du Nord": :Retail,
      Europe: :Business,
      Europe: :Créa,
      "N/A": :"Marketing / Comm'",
      Asie: :Business
    ]

    table = """
    +------------------+-------+----------+---------+------+-------------------+--------+
    |                  | TOTAL | Business | Conseil | Créa | Marketing / Comm' | Retail |
    +------------------+-------+----------+---------+------+-------------------+--------+
    | TOTAL            | 11    | 4        | 1       | 1    | 4                 | 1      |
    | Amérique du Nord | 1     | 0        | 0       | 0    | 0                 | 1      |
    | Asie             | 1     | 1        | 0       | 0    | 0                 | 0      |
    | Europe           | 8     | 3        | 1       | 1    | 3                 | 0      |
    | N/A              | 1     | 0        | 0       | 0    | 1                 | 0      |
    +------------------+-------+----------+---------+------+-------------------+--------+

    """

    assert capture_io(fn -> JobsWorldwide.Table.create_table(list) end) == table
  end
end
