defmodule JobsWorldwideTest do
  use ExUnit.Case
  doctest JobsWorldwide

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

  test "Jobs CSV parsing is correctly handled" do
    csv_file = "test/fixtures/jobs_test.csv"

    list = [
      %{location: :Europe, category: :Créa},
      %{location: :"Amérique du Nord", category: :Tech},
      %{location: :Europe, category: :Business},
      %{location: :"N/A", category: :"N/A"}
    ]

    assert JobsWorldwide.CSVParser.map_jobs(csv_file) |> Enum.to_list() == list
  end
end
