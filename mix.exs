defmodule XGen.MixProject do
  use Mix.Project

  def project do
    [
      app: :xgen,
      version: "0.3.0-dev",
      elixir: "~> 1.6",
      escript: [main_module: XGen],
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
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},

      # Project dependencies
      {:ex_cli, "~> 0.1.4"},
      {:typed_struct, "~> 0.1.3", runtime: false},

      # Documentation dependencies
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
