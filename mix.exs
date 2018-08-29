defmodule XGen.MixProject do
  use Mix.Project

  def project do
    [
      app: :xgen,
      version: "0.2.9",
      elixir: "~> 1.6",
      deps: deps()
    ]
  end

  def application do
    [extra_applications: []]
  end

  defp deps do
    [{:credo, "~> 0.10.0", only: :dev, runtime: false}]
  end
end
