defmodule AirShop.MixProject do
  use Mix.Project

  def project do
    [
      app: :air_shop,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AirShop.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:soap, "~> 1.0"},
      {:xml_builder, "~> 2.1.1"},
      {:sweet_xml, "~> 0.6.6"},
      {:poolboy, "~> 1.5.1"}
    ]
  end
end
