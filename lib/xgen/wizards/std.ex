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
    info([:bright, "\n*** Standard Elixir project ***\n"])

    {path, elixir_opts} = ElixirBase.run()

    user_opts = [
      sup: yes?("Generate a supervision tree?", false),
      rel: yes?("Add Distillery with a configuration?", false),
      contrib: yes?("Add a CONTRIBUTING.md?", false),
      package: yes?("Add package information?", false),
      license: LicenseChooser.run(),
      todo: yes?("Create a TODO file?", false),
      # TODO: Remove double negation.
      no_git: !yes?("Initialise a git repository?")
    ]

    info("\nGenerating the project...")
    XGen.generate(:std, path, opts ++ elixir_opts ++ user_opts)
  end
end
