defmodule XGen.MixProject do
  use Mix.Project

  def project do
    [
      app: :xgen,
      version: "0.3.3" <> dev(),
      elixir: "~> 1.7",
      escript: [main_module: XGen],
      deps: deps(),

      # Tools
      dialyzer: dialyzer(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: cli_env(),

      # Docs
      docs: [
        main: "XGen"
      ]
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
      {:excoveralls, ">= 0.0.0", only: :test, runtime: false},
      {:mix_test_watch, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_unit_notifier, ">= 0.0.0", only: :test, runtime: false},
      {:stream_data, "~> 0.4.0", only: :test},

      # Project dependencies
      {:ex_cli, "~> 0.1.6"},
      {:marcus, "~> 0.1.1"},
      {:typed_struct, "~> 0.1.3", runtime: false},

      # Documentation dependencies
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  # Dialyzer configuration
  defp dialyzer do
    [
      plt_add_deps: :transitive,
      flags: [
        :unmatched_returns,
        :error_handling,
        :race_conditions
      ],
      ignore_warnings: ".dialyzer_ignore"
    ]
  end

  defp cli_env do
    [
      # Always run coveralls mix tasks in `:test` env.
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.html": :test
    ]
  end

  # Helper to add a development revision to the version. Do NOT make a call to
  # Git this way in a production release!!
  def dev do
    with {rev, 0} <-
           System.cmd("git", ["rev-parse", "--short", "HEAD"],
             stderr_to_stdout: true
           ) do
      "-dev+" <> String.trim(rev)
    else
      _ -> "-dev"
    end
  end
end
