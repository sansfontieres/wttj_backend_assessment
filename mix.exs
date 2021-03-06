defmodule JobsWorldwide.MixProject do
  use Mix.Project

  def project do
    [
      app: :jobs_worldwide,
      version: "0.1.0",
      elixir: "~> 1.12",
      escript: [main_module: JobsWorldwide],
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      docs: [
        extras: ["README.md"],
        main: "readme"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {JobsWorldwide.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:jason, "~> 1.2"},
      {:nimble_csv, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:plug_etf, "~> 0.1.0"},
      {:table_rex, "~> 3.1.1"},
      {:topo, "~> 0.4.0"}
    ]
  end
end
