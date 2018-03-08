defmodule ExGen.Project do
  @moduledoc """
  A project struct.
  """

  @fields quote(
            do: [
              type: ExGen.project_type(),
              path: String.t(),
              app: String.t(),
              mod: String.t(),
              opts: keyword(),
              assigns: keyword(),
              collections: [atom()],
              build: boolean()
            ]
          )

  defstruct Keyword.keys(@fields)

  @type t() :: %__MODULE__{unquote_splicing(@fields)}

  @doc """
  Creates a new project.
  """
  @spec new(ExGen.project_type(), String.t(), keyword()) :: t()
  def new(type, path, opts) do
    path = Path.expand(path)
    app = opts[:app] || Path.basename(path)
    mod = opts[:module] || Macro.camelize(app)

    %__MODULE__{
      type: type,
      path: path,
      app: app,
      mod: mod,
      opts: opts,
      assigns: [],
      collections: [],
      build: false
    }
  end
end
