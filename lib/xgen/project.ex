defmodule XGen.Project do
  @moduledoc """
  A project struct.
  """

  use TypedStruct

  alias XGen.Templates

  typedstruct enforce: true do
    field :type, XGen.project_type()
    field :path, String.t()
    field :app, String.t()
    field :mod, String.t()
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
