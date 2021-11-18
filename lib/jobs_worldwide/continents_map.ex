defmodule JobsWorldwide.ContinentsMap do
  @moduledoc """
    A coordinate to continent converter.

    Rationale: A pair of latitude and longitude coordinates are points on a
    map. By combining points we get a geometric figure which its coordinates
    represents a continent. Therefore, if we can pinpoint an office location
    into one of those areas, we can confirm on which continent it is located.
    
    Credit to: https://stackoverflow.com/a/25075832
  """

  @continents [
    %{
      continent: :"Amérique du Nord",
      type: "Polygon",
      coordinates: [
        [
          {90, -168.75},
          {90, -10},
          {78.13, -10},
          {57.5, -37.5},
          {15, -30},
          {15, -75},
          {1.25, -82.5},
          {1.25, -105},
          {51, -180},
          {60, -180},
          {60, -168.75}
        ]
      ]
    },
    %{
      continent: :"Amérique du Nord",
      type: "Polygon",
      coordinates: [
        [{51, 166.6}, {51, 180}, {60, 180}]
      ]
    },
    %{
      continent: :"Amérique du Sud",
      type: "Polygon",
      coordinates: [
        [
          {1.25, -105},
          {1.25, -82.5},
          {15, -75},
          {15, -30},
          {-60, -30},
          {-60, -105}
        ]
      ]
    },
    %{
      continent: :Europe,
      type: "Polygon",
      coordinates: [
        [
          {90, -10},
          {90, 77.5},
          {42.5, 48.8},
          {42.5, 30},
          {40.79, 28.81},
          {41, 29},
          {40.55, 27.31},
          {40.4, 26.75},
          {40.05, 26.36},
          {39.17, 25.19},
          {35.46, 27.91},
          {33, 27.5},
          {38, 10},
          {35.42, -10},
          {28.25, -13},
          {15, -30},
          {57.5, -37.5},
          {78.13, -10}
        ]
      ]
    },
    %{
      continent: :Afrique,
      type: "Polygon",
      coordinates: [
        [
          {15, -30},
          {28.25, -13},
          {35.42, -10},
          {38, 10},
          {33, 27.5},
          {31.74, 34.58},
          {29.54, 34.92},
          {27.78, 34.46},
          {11.3, 44.3},
          {12.5, 52},
          {-60, 75},
          {-60, -30}
        ]
      ]
    },
    %{
      continent: :Asie,
      type: "Polygon",
      coordinates: [
        [
          {90, 77.5},
          {42.5, 48.8},
          {42.5, 30},
          {40.79, 28.81},
          {41, 29},
          {40.55, 27.31},
          {40.4, 26.75},
          {40.05, 26.36},
          {39.17, 25.19},
          {35.46, 27.91},
          {33, 27.5},
          {31.74, 34.58},
          {29.54, 34.92},
          {27.78, 34.46},
          {11.3, 44.3},
          {12.5, 52},
          {-60, 75},
          {-60, 110},
          {-31.88, 110},
          {-11.88, 110},
          {-10.27, 140},
          {33.13, 140},
          {51, 166.6},
          {60, 180},
          {90, 180}
        ]
      ]
    },
    %{
      continent: :Asie,
      type: "Polygon",
      coordinates: [
        [{90, -180}, {90, -168.75}, {60, -168.75}, {60, -180}]
      ]
    },
    %{
      continent: :Océanie,
      type: "Polygon",
      coordinates: [
        [
          {-11.88, 110},
          {-10.27, 140},
          {-10, 145},
          {-30, 161.25},
          {-52.5, 142.5},
          {-31.88, 110}
        ]
      ]
    },
    %{
      continent: :Antartique,
      type: "Polygon",
      coordinates: [
        [{-60, -180}, {-60, 180}, {-90, 180}, {-90, -180}]
      ]
    }
  ]

  @doc """
  Returns an atom with the continent name (in french) from the latitude and
  the longitude of a location. If the location points somewhere not covered
  by a continent area, it returns a dummy atom.

  Example:
      iex> JobsWorldwide.ContinentsMap.get_continent(10, 10)
      :Afrique
      iex> JobsWorldwide.ContinentsMap.get_continent(100, 100)
      :"N/A"
  """
  @spec get_continent(number, number) :: atom
  def get_continent(latitude, longitude) do
    location = %{type: "Point", coordinates: {latitude, longitude}}

    case Enum.find(@continents, fn area -> Topo.contains?(area, location) end) do
      %{continent: continent} -> continent
      _ -> :"N/A"
    end
  end
end
