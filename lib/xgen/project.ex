defmodule XGen.Project do
  @moduledoc """
  A project struct.
  """

  use TypedStruct

  alias XGen.Templates

  typedstruct do
    field :type, XGen.project_type(), enforce: true
    field :path, String.t(), enforce: true
    field :app, String.t(), enforce: true
    field :mod, String.t(), enforce: true
    field :opts, keyword(), default: []
    field :assigns, keyword(), default: []
    field :collection, Templates.collection(), default: []
    field :build, boolean(), default: false
  end

  @doc """
  Creates a new project.
  """
  @spec new(XGen.project_type(), String.t(), keyword()) :: t()
  def new(type, path, opts) do
    app = opts[:app] || Path.basename(path)
    mod = opts[:module] || Macro.camelize(app)

    %__MODULE__{
      type: type,
      path: path,
      app: app,
      mod: mod,
      opts: opts
    }
  end
end
