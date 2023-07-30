defmodule Roundtable.MixProject do
  use Mix.Project

  def project do
    [
      app: :roundtable,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Roundtable.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Parse JSON
      {:jason, "~> 1.4"},
      # Parse Environment Vars
      {:dotenv_parser, "~> 2.0"},
      {:plug_cowboy, "~> 2.6.1"},
      {:mongodb_driver, "~> 1.0.0"},
      # Static code analysis
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      # Parse CSV
      {:nimble_csv, "~> 1.1"},
      # HTTP client for Elixir
      {:httpoison, "~> 2.1"}
    ]
  end
end
