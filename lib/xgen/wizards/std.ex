defmodule XGen.Wizards.Std do
  @moduledoc """
  A wizard to setup standard Elixir projects.
  """

  use XGen.Wizard

  @licenses [
    mit: "MIT License"
  ]

  @license_codes [
    mit: "MIT"
  ]

  @impl true
  @spec run(keyword()) :: :ok
  def run(opts \\ []) do
    info([:bright, "\n*** Standard Elixir project ***\n"])

    path = prompt_mandatory("Project directory")
    app = prompt("OTP application name", Path.basename(path))

    user_opts = [
      app: app,
      module: prompt("Module name", Macro.camelize(app)),
      sup: yes?("Generate a supervision tree?", false),
      rel: yes?("Add Distillery with a configuration?", false),
      contrib: yes?("Add a CONTRIBUTING.md?", false),
      package: yes?("Add package information?", false),
      license: license(),
      todo: yes?("Create a TODO file?", false),
      # TODO: Remove double negation.
      no_git: !yes?("Initialise a git repository?")
    ]

    info("\nGenerating the project...")
    XGen.generate(:std, path, opts ++ user_opts)
  end

  @spec license :: String.t() | nil
  defp license do
    if yes?("Add a license?", false) do
      key = choose("Which license to add?", @licenses)
      Keyword.get(@license_codes, key)
    end
  end
end
