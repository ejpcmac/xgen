defmodule <%= @mod %>.MixProject do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"

  def project do
    [
      app: :<%= @app %>,
      version: "0.1.0-dev",
      elixir: "~> 1.6",
      target: @target,
      archives: [nerves_bootstrap: "~> 1.0"],
      deps_path: "deps/#{@target}",
      build_path: "_build/#{@target}",
      lockfile: "mix.lock.#{@target}",
      start_permanent: Mix.env() == :prod,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps()
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config().
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Use a different application for target-specific operations.
  def application, do: application(@target)

  def application("host") do
    [extra_applications: [:logger]]
  end

  def application(_target) do
    [<%= if @sup do %>
      mod: {<%= @mod %>.Application, []},<% end %>
      extra_applications: [:logger<%= if @ssh do %>, :ssh<% end %>]
    ]
  end

  # General dependencies
  defp deps do
    [
      {:nerves, "~> 1.0", runtime: false}
    ] ++ deps(@target)
  end

  # Target-specific dependencies
  defp deps("host"), do: []

  defp deps(target) do
    [
      system(target),
      {:shoehorn, "~> 0.3.0"},
      {:nerves_runtime, "~> 0.6.0"}<%= if @net do %>,
      {:nerves_network, "~> 0.3.7-rc"}<% end %><%= if @push do %>,
      {:nerves_firmware_ssh, "~> 0.3.0"}<% end %><%= if @ssh do %>,
      {:nerves_runtime_shell, "~> 0.1.0"}<% end %><%= if @ntp do %>,
      {:nerves_ntp, github: "evokly/nerves_ntp"}<% end %><%= if @rtc do %>,
      {:rtc_ds3231, "~> 0.1.0"}<% end %>
    ]
  end
<%= for target <- [
          "rpi",
          "rpi0",
          "rpi2",
          "rpi3",
          "bbb",
          "ev3",
          "qemu_arm",
          "x86_64"
        ] do %>
  defp system("<%= target %>"), do: {:nerves_system_<%= target %>, "~> 1.2", runtime: false}<% end %>
  defp system(target), do: Mix.raise("Unknown MIX_TARGET: #{target}")
end
