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

  pregen :cookie_generator

  collection do
    [
      "base/README.md.eex",
      "base/CHANGELOG.md",
      "base/shell.nix.eex",
      "base/.envrc",
      "base/.editorconfig",
      "std/.formatter.exs.eex",
      "base/.credo.exs",
      "base/.dialyzer_ignore",
      "base/.gitignore.eex",
      "std/mix.exs.eex",
      "std/config/config.exs",
      "std/lib/@app@.ex.eex",
      "std/test/support/",
      "std/test/test_helper.exs",
      "std/test/@app@_test.exs.eex"
    ]
  end

  collection @sup?, do: ["std/lib/@app@/application.ex.eex"]

  collection @release? do
    [
      "std/rel/plugins/.gitignore",
      "std/rel/config.exs.eex"
    ]
  end

  collection @contributing?, do: ["base/CONTRIBUTING.md.eex"]
  collection @license?, do: ["base/LICENSE+#{@license}.eex"]
  collection @git?, do: ["base/.gitsetup"]

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
