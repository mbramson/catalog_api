defmodule CatalogApi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :catalog_api,
      version: "0.0.17",
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "CatalogApi",
      source_url: "https://github.com/mbramson/catalog_api"
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
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19.0", only: :dev, runtime: false},
      {:httpoison, "~> 1.0"},
      {:jason, "~> 1.1"},
      {:mix_test_watch, "~> 0.6", only: :dev, runtime: false},
      {:mock, "~> 0.3.0", only: :test},
      {:quixir, "~> 0.9", only: :test },
      {:uuid, "~> 1.1" },
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp description() do
    """
    CatalogApi is a client for the catalogapi.com API.
    """
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Mathew Bramson"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mbramson/catalog_api"}
    ]
  end
end
