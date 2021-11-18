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
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:nimble_csv, "~> 1.1"},
      {:topo, "~> 0.4.0"}
    ]
  end
end
