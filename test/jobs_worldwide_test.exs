defmodule JobsWorldwideTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO
  use Plug.Test

  @opts JobsWorldwide.Router.init([])

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

    map = %{
      "28" => :Créa,
      "14" => :Tech,
      "1" => :Business
    }

    assert JobsWorldwide.CSVParser.map_professions(professions_csv) == map
  end

  test "Jobs CSV parsing is correctly handled" do
    jobs_csv = parse_csv("test/fixtures/jobs_test.csv")
    professions_csv = parse_csv("test/fixtures/professions_test.csv")

    list = [
      EUROPE: :CRÉA,
      "AMÉRIQUE DU NORD": :TECH,
      EUROPE: :BUSINESS,
      "N/A": :"N/A"
    ]

    assert JobsWorldwide.CSVParser.map_jobs(jobs_csv, professions_csv) == list
  end

  test "Offers list gets correctly processed into a table" do
    list = [
      EUROPE: :"MARKETING / COMM'",
      EUROPE: :"MARKETING / COMM'",
      EUROPE: :BUSINESS,
      EUROPE: :"MARKETING / COMM'",
      EUROPE: :CONSEIL,
      EUROPE: :BUSINESS,
      "AMÉRIQUE DU NORD": :RETAIL,
      EUROPE: :BUSINESS,
      EUROPE: :CRÉA,
      "N/A": :"MARKETING / COMM'",
      ASIE: :BUSINESS
    ]

    table = """
    +------------------+-------+----------+---------+------+-------------------+--------+
    |                  | TOTAL | BUSINESS | CONSEIL | CRÉA | MARKETING / COMM' | RETAIL |
    +------------------+-------+----------+---------+------+-------------------+--------+
    | TOTAL            | 11    | 4        | 1       | 1    | 4                 | 1      |
    | AMÉRIQUE DU NORD | 1     | 0        | 0       | 0    | 0                 | 1      |
    | ASIE             | 1     | 1        | 0       | 0    | 0                 | 0      |
    | EUROPE           | 8     | 3        | 1       | 1    | 3                 | 0      |
    | N/A              | 1     | 0        | 0       | 0    | 1                 | 0      |
    +------------------+-------+----------+---------+------+-------------------+--------+

    """

    assert capture_io(fn -> JobsWorldwide.Table.create_table(list) end) == table
  end

  @etf_mime "application/x-erlang-binary"

  test "Router returns a greeting" do
    conn = conn(:get, "/")
    json_conn = JobsWorldwide.Router.call(conn, @opts)
    etf_conn = conn |> put_req_header("accept", @etf_mime)
    etf_conn = JobsWorldwide.Router.call(etf_conn, @opts)

    assert json_conn.state == :sent
    assert json_conn.status == 200
    assert json_conn.resp_body == "[{\"Hello\": \"World\"}]"

    assert etf_conn.state == :sent
    assert etf_conn.status == 200
    assert etf_conn.resp_body |> :erlang.binary_to_term() == ["Hello", "World"]
  end

  test "Router returns a \"malformed_query\" on invalid query" do
    conn = conn(:get, "/offers/cantinent=europe")
    json_conn = JobsWorldwide.Router.call(conn, @opts)
    etf_conn = conn |> put_req_header("accept", @etf_mime)
    etf_conn = JobsWorldwide.Router.call(etf_conn, @opts)

    assert json_conn.state == :sent
    assert json_conn.status == 200
    assert json_conn.resp_body == "\"malformed_query\""

    assert etf_conn.state == :sent
    assert etf_conn.status == 200
    assert etf_conn.resp_body |> :erlang.binary_to_term() == :malformed_query
  end

  test "Router returns 404 on unmatched routes" do
    conn = conn(:get, "/no_clue")
    conn = JobsWorldwide.Router.call(conn, @opts)

    assert conn.status == 404
  end
end
