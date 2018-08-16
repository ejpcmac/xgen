defmodule <%= @mod %>.MixProject do
  use Mix.Project

  @version "0.1.0-dev"
  <%= unless @package, do: "# " %>@repo_url "https://github.com/<%= @github_account %>/<%= @app %>"

  def project do
    [
      app: :<%= @app %>,
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Tools
      dialyzer: dialyzer(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: cli_env(),

      # Docs
      docs: [
        main: "<%= @mod %>"<%= if @package, do: "," %>
        <%= unless @package, do: "# " %>source_url: @repo_url,
        <%= unless @package, do: "# " %>source_ref: "v#{@version}"
      ]<%= if @package do %>,

      # Package
      package: package(),
      description: "Description for <%= @mod %>."<% end %>
    ]
  end

  def application do
    [<%= if @sup do %>
      mod: {<%= @mod %>.Application, []},<% end %>
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Development and test dependencies
      {:credo, "~> 0.10.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, ">= 0.0.0", only: :test, runtime: false},
      {:mix_test_watch, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_unit_notifier, ">= 0.0.0", only: :test, runtime: false},
      {:stream_data, "~> 0.4.0", only: :test},

      # Project dependencies

      # Documentation dependencies
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}<%= if @rel do %>,

      # Release dependencies
      {:distillery, "~> 2.0"}<% end %>
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
  end<%= if @package do %>

  defp package do
    [<%= if @license do %>
      licenses: ["<%= @license %>"],<% end %>
      links: %{"GitHub" => @repo_url}
    ]
  end<% end %>
end
