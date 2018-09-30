defmodule XGen.Wizards.ElixirBase do
  @moduledoc """
  A wizard to configure bare minimum options for Elixir projects.
  """

  use XGen.Wizard

  @impl true
  @spec run :: {String.t(), keyword()}
  @spec run(keyword()) :: {String.t(), keyword()}
  def run(_opts \\ []) do
    path = prompt("Project directory", required: true)
    app = prompt("OTP application name", default: Path.basename(path))
    module = prompt("Module name", default: Macro.camelize(app))

    elixir_opts = [
      app: app,
      module: module,
      sup: sup?(module)
    ]

    {path, elixir_opts}
  end

  defp sup?(module) do
    doc(
      "Supervision tree",
      """
      xgen can generate for you the module #{module}.Application containing a
      supervision tree. It also updates the application configuration in the
      mix.exs.
      """
    )

    yes?("Generate a supervision tree?", :no)
  end
end
