defmodule XGen.Properties do
  @moduledoc """
  Helpers to create domain-specific behaviours with properties to set.

  *Properties* are defined as constant functions. A module using
  `XGen.Properties` can define property callbacks and helper macros to implement
  the functions without writing boilerplate code.

  ## Example

  Let’s define a behaviour with some properties to set:

      defmodule MyBehaviour do
        use XGen.Properties

        # Each defined property results in a @callback and a macro.
        defproperty :name, String.t()
        defproperty :options, keyword()
      end

  Then, it is possible do define modules setting those properties:

      defmodule MyImplentation do
        use MyBehaviour  # MyBehaviour is use-able out of the box.

        # Macros named from properties help implement the callbacks.
        name "My implementation"
        options an_option: :great, a_string: "Yay!"
      end

  ## Behind the scenes

  When *use*-ing `XGen.Properties`, a `__using__/1` macro is automatically
  defined so the module becomes itself *use*-able:

      defmacro __using__(_opts) do
        quote do
          @behaviour MyBehaviour
          import MyBehaviour
        end
      end

  This macro is made overridable, so if you need to add some code to
  `__using__/1` you can use the `using/1` macro:

      using do
        quote do
          # Insert here some code to add after the default __using__/1 contents.
        end
      end

  Each `defproperty/2` call generates both a callback and a helper macro:

      defproperty :name, String.t()

      ## Generates

      @callback name :: String.t()

      defmacro name(value) do
        quote do
          @impl true
          def name, do: unquote(value)
        end
      end

  This way, when you define an implementation of this behaviour, you can write:

      name "Example"

  instead of:

      @impl true
      def name, do: "Example"
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      defmacro __using__(_opts) do
        quote do
          @behaviour unquote(__MODULE__)
          import unquote(__MODULE__)
        end
      end

      defoverridable __using__: 1
    end
  end

  @doc ~S"""
  Customises the `__using__/1` macro by adding code after its default content.

  ## Example

      defmodule MyBehaviour do
        use XGen.Properties

        using opts do
          quote do
            if opts[:name] do
              IO.puts("The name is #{name}, this is printed during compilation")
            end
          end
        end
      end

  This is equivalent to:

      defmodule MyBehaviour do
        use XGen.Properties

        defmacro __using__(opts) do
          quote do
            @behaviour MyBehaviour
            import MyBehaviour

            if opts[:name] do
              IO.puts("The name is #{name}, this is printed during compilation")
            end
          end
        end
      end
  """
  defmacro using(var \\ quote(do: _), do: block) do
    quote do
      defmacro __using__(unquote(var) = opts) do
        block = unquote(block)

        quote do
          @behaviour unquote(__MODULE__)
          import unquote(__MODULE__)
          unquote(block)
        end
      end
    end
  end

  @doc """
  Defines a property.

  A property is a constant function to be defined by modules implementing the
  behaviour. This macro defines a callback and a macro to help define its
  implementation. This aims to provide a domain-specific language to create
  domain-specific modules.

  ## Options

    * `doc` - documentation for the property. It is prefixed by *Returns* in the
      callback documentation and *Sets* in the macro documentation.
    * `optional` - if set to `true`, makes the property optional.

  ## Example

      defmodule MyModule do
        import XGen.Property

        defproperty :name, String.t(), doc: "the name"
        defproperty :options, keyword(), doc: "the list of options"
      end
  """
  defmacro defproperty(name, type, opts \\ []) do
    doc = opts[:doc]
    optional = !!opts[:optional]

    quote do
      if unquote(doc) do
        @doc "Returns #{unquote(doc)}."
      end

      @callback unquote(name)() :: unquote(type)

      if unquote(optional) do
        @optional_callbacks {unquote(name), 0}
      end

      if unquote(doc) do
        @doc "Sets #{unquote(doc)}."
      end

      defmacro unquote(name)(value) do
        name = unquote(name)

        quote do
          @impl true
          def unquote(name)(), do: unquote(value)
        end
      end
    end
  end
end
