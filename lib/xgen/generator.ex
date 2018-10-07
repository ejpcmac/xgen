defmodule XGen.Generator do
  @moduledoc """
  Helpers to create and run project generators.

  When generating a project, `xgen` goes through a few phases:

    1. the generator name is printed,
    2. the user is asked a few questions to configure the project,
    3. optional pre-generation callbacks are run,
    4. a collection of templates is built,
    5. files are generated and copied,
    6. optional post-generation callbacks are run.

  Each of these phases are declared in a generator by using a domain-specific
  language. Let’s go through an example:

      # A generator is simply a module with some properties.
      defmodule MyGenerator do
        @moduledoc \"""
        A generator.
        \"""

        # Sets the XGen.Generator behaviour and imports the macros.
        use XGen.Generator

        # Import some useful post-generation callbacks.
        import XGen.Generator.StandardCallbacks

        # Some standard options are defined here.
        alias XGen.Options.Base

        # Sets the project type. This value is then accessible via the @type
        # assign in templates. It can sometimes be useful when templates are
        # shared between generators but require some specific customisations.
        type :my_project

        # The printable generator name
        name "My project"

        # This is the list of options. The user will be asked to resolve each
        # of these in the order they are declared. Base.Path is automatically
        # added as first option, so you don’t need to state it.
        options [
          MyOption,
          Script,
          BuildScript,
          Base.License,
          Base.Git
        ]

        # Pre-generation scripts can be registered here. They are functions that
        # takes the map of resolved options as argument and return an updated
        # map. If multiple pre-generation scripts are registered, they are
        # executed in the order they are declared here
        #
        # :secret_key is defined at the end of this module so you can see a
        # simple example.
        pregen :secret_key

        # This is the default collection. All the templates listed here will be
        # added to the project.
        collection do
          [
            "base/README.md",
            "base/CHANGELOG.md",
            "base/shell.nix.eex",
            "base/.envrc",
            "base/.editorconfig",
            "my_project/useful_file"
          ]
        end

        # With collection/2, you can optionally add some files to the
        # collection. The first parameter is the condition to add the templates
        # to the collection. You can use options values in the form of
        # @option_key.
        collection @my_option? do
          [
            "my_project/some_optional_file",
            "my_project/some_directory/some_other_file.eex"
          ]
        end

        collection @script == :script_a, do: ["my_project/script_a"]
        collection @build_script?, do: ["my_project/build"]

        # You can even use option values to choose dynamically a template.
        collection @license?, do: ["base/LICENSE+\#{@license}.eex"]

        # In the same way as pre-generation scripts, post-generation scripts
        # take the map of option and return an optionally updated map. They are
        # mainly made to perform tasks like running commands in the newly
        # generated project and print some information to the user.
        #
        # :fix_permissions and :build_instructions are defined below, while
        # :init_git and :project_created are standard callbacks defined in
        # XGen.Generator.StandardCallbacks so you can use them in your projects.
        postgen :fix_permissions
        postgen :init_git
        postgen :project_created
        postgen :build_instructions

        # In addition to the domain-specific macros, you can write any Elixir
        # code you like. You can see below some examples of pre and
        # post-generation callbacks.

        ##
        ## Pre-generation callbacks
        ##

        @spec secret_key(map()) :: map()
        defp secret_key(opts) do
          # NOTE: Since we have aliased XGen.Options.Base, we must use here
          # Elixir.Base.
          key = 32 |> :crypto.strong_rand_bytes() |> Elixir.Base.encode64()
          Map.put(opts, :secret_key, key)
        end

        ##
        ## Post-generation callbacks
        ##

        @spec fix_permissions(map()) :: map()
        defp fix_permissions(opts) do
          if opts[:script] == :script_a, do: File.chmod!("script_a", 0o755)
          if opts[:build_script?], do: File.chmod!("build", 0o755)
          opts
        end

        @spec build_instructions(map()) :: map()
        defp build_instructions(opts) do
          if opts[:build_script?] do
            Marcus.info(\"""
            You can now build the project:

                cd \#{opts.path}
                ./build
            \""")
          end

          opts
        end
      end

  ## Running generators

  Once defined, generators can be run by `run/2`:

      iex> XGen.Generator.run(MyGenerator, config)

      === My project ===

      Project directory: some_directory
      ...

  where `config` is a map containing configuration options, like your name,
  GitHub account and so on. It should be read from a configuration file.
  """

  use XGen.Properties

  alias XGen.Option
  alias XGen.Templates

  @typedoc "A project generator"
  @type t() :: module()

  defproperty :type, atom(), doc: "the project type"
  defproperty :name, String.t(), doc: "the generator name"
  defproperty :options, [Option.t()], doc: "the list of options"

  using do
    quote do
      @before_compile unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :pregen, accumulate: true)
      Module.register_attribute(__MODULE__, :postgen, accumulate: true)
      Module.put_attribute(__MODULE__, :collection_num, 0)

      # Define the collection 0 to ensure the generator compiles even if no
      # collection is defined.
      defp get_collection(0, _), do: []
    end
  end

  @doc """
  Registers a collection.
  """
  defmacro collection(condition \\ true, do: block) do
    parsed_condition = Macro.prewalk(condition, &EEx.Engine.handle_assign/1)
    parsed_block = Macro.prewalk(block, &EEx.Engine.handle_assign/1)

    # Do not generate conditional code if the condition is true to avoid
    # Dialyzer to complain.
    conditional_block =
      if condition == true do
        parsed_block
      else
        quote do
          if unquote(parsed_condition), do: unquote(parsed_block), else: []
        end
      end

    quote do
      @collection_num @collection_num + 1

      defp get_collection(@collection_num, var!(assigns)) do
        _ = var!(assigns)
        unquote(conditional_block)
      end
    end
  end

  @doc """
  Registers a pre-generation callback.
  """
  defmacro pregen(callback) do
    quote do
      Module.put_attribute(__MODULE__, :pregen, unquote(callback))
    end
  end

  @doc """
  Registers a post-generation callback.
  """
  defmacro postgen(callback) do
    quote do
      Module.put_attribute(__MODULE__, :postgen, unquote(callback))
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    pregens = callback_chain(env.module, :pregen)
    postgens = callback_chain(env.module, :postgen)

    quote do
      @doc false
      @spec __build_collection__(map()) :: XGen.Templates.collection()
      def __build_collection__(opts) do
        Enum.flat_map(0..@collection_num, &get_collection(&1, opts))
      end

      @doc false
      @spec __pregen__(map()) :: map()
      def __pregen__(opts) do
        (unquote_splicing(pregens))
        opts
      end

      @doc false
      @spec __postgen__(map()) :: :ok
      def __postgen__(opts) do
        (unquote_splicing(postgens))
        :ok
      end
    end
  end

  @spec callback_chain(module(), atom()) :: Macro.t()
  defp callback_chain(module, name) do
    module
    |> Module.get_attribute(name)
    |> Enum.reduce([], fn callback, acc ->
      block = quote do: opts = unquote(callback)(opts)
      [block | acc]
    end)
  end

  @doc """
  Runs the given `generator`.
  """
  @spec run(t(), map()) :: :ok
  def run(generator, %{} = config) do
    Marcus.info([:bright, "\n=== #{generator.name()} ===\n"])

    # Always ask for the project directory.
    options = [XGen.Options.Base.Path | generator.options()]

    opts =
      options
      |> Enum.reduce(config, &Option.resolve/2)
      |> Map.put(:type, generator.type())
      |> generator.__pregen__()

    collection = generator.__build_collection__(opts)

    Marcus.info("\nGenerating the project...")

    File.mkdir_p!(opts.path)
    File.cd!(opts.path)
    Templates.copy(collection, opts)

    generator.__postgen__(opts)
  end
end
