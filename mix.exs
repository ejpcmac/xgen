defmodule ExGen.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_gen,
      version: "0.2.1-dev",
      elixir: "~> 1.6",
      deps: deps()
    ]
  end

  def application do
    [extra_applications: []]
  end

  defp deps do
    [{:credo, "~> 0.8.10", only: :dev, runtime: false}]
  end
end
