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
    [extra_applications: []]
  end

  defp deps do
    [
      {:credo, "~> 0.10.0", only: :dev, runtime: false},
      {:typed_struct, "~> 0.1.1", runtime: false}
    ]
  end
end
