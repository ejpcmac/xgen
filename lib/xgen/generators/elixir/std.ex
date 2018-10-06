defmodule XGen.Generators.Elixir.Std do
  @moduledoc """
  A generator for standard Elixir projects.
  """

  use XGen.Generator

  import XGen.Generator.CallbackHelpers
  import XGen.Generator.StandardCallbacks
  import XGen.Generators.Elixir.Callbacks

  alias XGen.Options.Base
  alias XGen.Options.Elixir.Base, as: ElixirBase
  alias XGen.Options.Elixir.Std, as: ElixirStd
  alias XGen.Wizard

  type :elixir_std

  name "Standard Elixir project"

  options [
    ElixirBase.Application,
    ElixirBase.Module,
    ElixirBase.SupervisionTree,
    ElixirStd.Release,
    ElixirStd.Contributing,
    ElixirStd.Package,
    Base.License,
    Base.Git
  ]

  pregen :module_path
  pregen :cookie_generator

  collection do
    [
      "_base_/README.md.eex",
      "_base_/CHANGELOG.md",
      "_elixir_/_base_/shell.nix.eex",
      "_base_/.envrc",
      "_base_/.editorconfig",
      "_elixir_/_std_/.formatter.exs.eex",
      "_elixir_/_base_/.credo.exs",
      "_elixir_/_base_/.dialyzer_ignore",
      "_elixir_/_base_/.gitignore.eex",
      "_elixir_/_std_/mix.exs.eex",
      "_elixir_/_std_/config/config.exs",
      "_elixir_/_std_/lib/@module_path@.ex.eex",
      "_elixir_/_std_/test/support/",
      "_elixir_/_std_/test/test_helper.exs",
      "_elixir_/_std_/test/@module_path@_test.exs.eex"
    ]
  end

  collection @sup?, do: ["_elixir_/_std_/lib/@module_path@/application.ex.eex"]

  collection @release? do
    [
      "_elixir_/_std_/rel/plugins/.gitignore",
      "_elixir_/_std_/rel/config.exs.eex"
    ]
  end

  collection @contributing?, do: ["_elixir_/_base_/CONTRIBUTING.md.eex"]
  collection @license?, do: ["_base_/LICENSE+#{@license}.eex"]
  collection @git?, do: ["_base_/.gitsetup"]

  postgen :init_git
  postgen :prompt_to_build
  postgen :project_created
  postgen :build_instructions
  postgen :gitsetup_instructions

  ##
  ## Post-generation callbacks
  ##

  @spec prompt_to_build(map()) :: map()
  defp prompt_to_build(opts) do
    msg =
      "\nFetch dependencies and build in dev and test environments in parallel?"

    if Wizard.yes?(msg, :yes) do
      run_command("mix", ["deps.get"])

      build_task =
        Task.async(fn ->
          run_command("mix", ["compile"])
          Wizard.green_info("=> project compilation complete")
        end)

      test_task =
        Task.async(fn ->
          run_command("mix", ["compile"], env: [{"MIX_ENV", "test"}])
          Wizard.green_info("=> tests compilation complete")
        end)

      Task.await(build_task, :infinity)
      Task.await(test_task, :infinity)
      Map.put(opts, :built?, true)
    else
      Map.put(opts, :built?, false)
    end
  end

  @spec build_instructions(map()) :: map()
  defp build_instructions(opts) do
    unless opts[:built?] do
      Wizard.info("""
      You can now fetch its dependencies and compile it:

          cd #{opts.path}
          mix deps.get
          mix compile

      You can also run tests:

          mix test
      """)
    end

    opts
  end
end
