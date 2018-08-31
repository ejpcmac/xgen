defmodule XGen.Wizards.Std do
  @moduledoc """
  A wizard to setup standard Elixir projects.
  """

  use XGen.Wizard

  alias XGen.Wizards.{ElixirBase, LicenseChooser}

  @impl true
  @spec run :: :ok
  @spec run(keyword()) :: :ok
  def run(opts \\ []) do
    info([:bright, "\n=== Standard Elixir project ===\n"])

    {path, elixir_opts} = ElixirBase.run()

    user_opts = [
      rel: release?(),
      contrib: contrib?(),
      package: package?(),
      license: LicenseChooser.run(),
      todo: yes?("Create a TODO file?", :no),
      git: yes?("Initialise a git repository?", :yes)
    ]

    info("\nGenerating the project...")
    XGen.generate(:std, path, opts ++ elixir_opts ++ user_opts)
  end

  defp release? do
    doc(
      "Release",
      """
      xgen can add Distillery to your project and generate a standard release
      configuration in rel/config.exs.
      """
    )

    yes?("Generate a release configuration?", :no)
  end

  defp contrib? do
    doc(
      "CONTRIBUTING.md",
      """
      xgen can add a CONTRIBUTING.md with generic instructions for Elixir
      projects hosted on GitHub. It covers all steps from forking to setting
      the environment and creating a pull request.
      """
    )

    yes?("Add a CONTRIBUTING.md?", :no)
  end

  defp package? do
    doc(
      "Package information",
      """
      If you are writing an Elixir library, you may want to publish it with Hex.
      In this case, xgen can add package information to the mix.exs so you don’t
      have to write it afterwards.
      """
    )

    yes?("Add package information?", :no)
  end
end
