defmodule Mix.Tasks.Xgen do
  use Mix.Task

  @shortdoc "Runs the interactive project generator."

  @moduledoc """
  Runs the interactive project generator.
  """

  alias XGen.Wizards.ConfigCreator

  import XGen.Wizard

  @version Mix.Project.config()[:version]

  @project_types [
    std: "Standard Elixir project",
    nerves: "Nerves project"
  ]

  @switches [
    config: :string
  ]

  @impl true
  @spec run([binary()]) :: :ok | no_return()
  def run(args) do
    info("xgen #{@version}\n")

    {opts, _argv} = OptionParser.parse!(args, strict: @switches)
    config_file = opts[:config] || user_home() |> Path.join(".xgen.exs")

    unless File.regular?(config_file) do
      ConfigCreator.run(file: config_file)
    end

    type = choose("Which kind of project do you want to start?", @project_types)

    info([
      :blue,
      """

      When the Wizard will exist, a project of type #{inspect(type)} will be
      generated.
      """
    ])
  end
end
