defmodule XGen.Wizards.ElixirBase do
  @moduledoc """
  A wizard to configure bare minimum options for Elixir projects.
  """

  use XGen.Wizard

  @impl true
  @spec run :: {String.t(), [app: String.t(), module: String.t()]}
  @spec run(keyword()) :: {String.t(), [app: String.t(), module: String.t()]}
  def run(_opts \\ []) do
    path = prompt_mandatory("Project directory")
    app = prompt("OTP application name", Path.basename(path))
    module = prompt("Module name", Macro.camelize(app))

    {path, [app: app, module: module]}
  end
end
