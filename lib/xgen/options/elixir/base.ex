defmodule XGen.Options.Elixir.Base do
  @moduledoc false

  use XGen.Option, collection: true

  defoption Application do
    key :app
    type :string
    default Path.basename(@path)
    prompt "OTP application name"

    @impl true
    @spec validator(String.t()) :: {:ok, String.t()} | {:error, String.t()}
    def validator(app) do
      if app =~ ~r/^[a-z][a-z0-9_]*$/ do
        {:ok, app}
      else
        message = """
        The OTP application name must start with a letter and have only
        lowercase letters, numbers and underscores. Got #{inspect(app)}."
        """

        {:error, message}
      end
    end
  end

  defoption Module do
    key :module
    type :string
    default Macro.camelize(@app)
    prompt "Module name"

    @impl true
    @spec validator(String.t()) :: {:ok, String.t()} | {:error, String.t()}
    def validator(module) do
      with :ok <- check_module_name_validity(module),
           :ok <- check_module_name_availability(module),
           do: {:ok, module}
    end

    @spec check_module_name_validity(String.t()) :: :ok | {:error, String.t()}
    defp check_module_name_validity(module) do
      if module =~ ~r/^[A-Z]\w*(\.[A-Z]\w*)*$/ do
        :ok
      else
        message =
          "The module name must be a valid Elixir alias (for example: " <>
            "Foo.Bar). Got #{inspect(module)}."

        {:error, message}
      end
    end

    @spec check_module_name_availability(String.t()) ::
            :ok | {:error, String.t()}
    defp check_module_name_availability(module) do
      module = Elixir.Module.concat(Elixir, module)

      if Code.ensure_loaded?(module) do
        message =
          "The module name #{inspect(module)} is already taken, please " <>
            "choose another name."

        {:error, message}
      else
        :ok
      end
    end
  end

  defoption SupervisionTree do
    key :sup?
    type :yesno
    default :no
    name "Supervision tree"
    prompt "Generate a supervision tree?"

    documentation """
    xgen can generate for you the module #{@module}.Application containing a
    supervision tree. It also updates the application configuration in the
    mix.exs.
    """
  end
end
