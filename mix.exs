defmodule XGen.MixProject do
  use Mix.Project

  def project do
    [
      app: :xgen,
      version: "0.3.0-dev",
      elixir: "~> 1.6",
      escript: [main_module: XGen.CLI],
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:eex]]
  end

  defp deps do
    [
      # Development dependencies
      {:credo, "~> 0.10.0", only: :dev, runtime: false},

      # Project dependencies

      # Documentation dependencies
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
