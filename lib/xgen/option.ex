defmodule XGen.Option do
  @moduledoc """
  Helpers to create and resolve generator options.

  Options have some properties do define:

    * `key` - the key to add in the options map after resolution
    * `type` - the option type
    * `default` - a default value *(optional)*
    * `options` - some options *(optional, see [Types and their
      options](#module-types-and-their-options))*
    * `name` - a printable name *(optional)*
    * `prompt` - the user prompt
    * `documentation` - documentation for the option *(optional)*

  If set, `name` and `documentation` need to be defined together.

  In addition to these properties, options can define an optional [validator
  callback](#module-validators).

  Options are declared as modules using a domain-specific language.

  ## Examples

  To define a single option, simply define a module `use`-ing `XGen.Option`.

      defmodule AnOption do
        @moduledoc false

        use XGen.Option

        key :an_option
        type :yesno
        default :yes
        name "An option"
        prompt "Activate the option?"

        documentation \"""
        This option enables the achievement of great things. If you choose to
        activate it (the default behaviour), you will not regret it.
        \"""
      end

  If you want to define multiple options in a module as a collection, you can
  use the `defoption` macro by `use`-ing `XGen.Option` with the `collection`
  option set:

      defmodule OptionCollection do
        @moduledoc false

        # `collection: true` imports only the defoption/2 macro and avoids
        # defining OptionCollection as an option.
        use XGen.Option, collection: true

        # `defoption` defines a module use-ing XGen.Option.
        defoption AnOption do
          key :an_option
          type :string
          options required: true
          prompt "Value"
        end

        defoption AnotherOption do
          key :another_option
          type :integer
          options range: 1..10
          prompt "Number of things"
        end
      end

  Values for all properties can be generated dynamically from other options
  values. For instance, if you are sure to run some `:project_name` option
  before to run the following one, you can write:

      defoption Module do
        key :module
        type :string
        default Macro.camelize(@project_name)
        prompt "Module name"
      end

  ## Types and their options

  ### Strings

  Options with the type `:string` prompt the user for a value. If no default
  value is set, pressing enter without writing a value sets the option to `""`.
  If a default value is set, it is printed in brackets after the prompt.
  Pressing enter without writing a value then sets the option to its default.

  Options for string options are:

    * `required` - if set to `true`, pressing enter without writing a value
      prints an error and prompts the user to enter a value again
    * `length` - an optional range for acceptable length

  For instance:

      defoption StringExample do
        name :string_example
        type :string
        options required: true, length: 3..20
        prompt "Project name"
      end

  ### Integers

  Options with the type `:integer` prompt the user for an integer value. If no
  default value is set, pressing enter without writing a value prints an error
  and prompts the user to enter a value again. If a default value is set, it is
  printed in brackets after the prompt. Pressing enter without writing a value
  then sets the option to its default.

  If the user input is not a valid integer, an error is printed and the user is
  asked to enter a new value.

  Options for integer options are:

    * `range` - an optional accepted range for the value. If set, the range is
      printed in parentheses after the prompt

  For instance:

      defoption IntegerExample do
        name :integer_example
        type :integer
        options range: 1..10
        prompt "Enter an integer"
      end

  ### Yes/no questions

  Options with the type `:yesno` ask for user confirmation. If no default value
  is set, `(y/n)` is printed after the prompt. Entering without a value is an
  error and the user is asked the question again. If a default value is set,
  either `[Y/n]` or `[y/N]` is printed after the prompt accordingly. Entering
  without a value sets the default value.

  Options for the yes/no questions are:

    * `if_yes` - an optional list of options to run if the user answers yes

  For instance:

      defoption YesNoExample do
        name :yesno_example
        type :yesno
        default :no
        options if_yes: [ChoiceExample]
        prompt "Do you want to add an item?"
      end

  ### Choices in a list

  Options with the type `:choice` prompt the user to choose a value from a list.
  If no default value is set, the user need to provide a choice. Else, hitting
  enter with an empty choice sets the default one.

  Options of this type **must** set the `:choices` option with a keyword list.
  Keys are potential values while values are strings printed to the user. For
  instance:

      defoption ChoiceExample do
        name :choice_example
        type :choice
        default :fork
        options choices: items()
        prompt "Which item to add?"

        defp choices do
          [
            spoon: "A spoon",
            fork: "A fork",
            knife: "A knife"
          ]
        end
      end

  This would print something like:

      Which item to add?

        1. A spoon
        2. A fork
        3. A knife

      Choice [2]:

  ## Validators

  If standard constraints like the length for strings or the range for integers
  are not sufficient, you can write a custom validator. A validator is a
  callback that takes the value as argument and returns either `{:ok,
  validated_value}` or `{:error, message}`:

      defoption ValidatedOption do
        key :validated_option
        type :string
        prompt "Email"

        @impl true
        def validator(value) do
          if value =~ ~r/@/,
            do: {:ok, String.downcase(value)},
            else: {:error, "The value must be a valid email."}
        end
      end

  ## Resolving options

  Options are meant to be resolved by a user input at some point. This can be
  achieved by using `resolve/2`, which takes the option as its first parameter
  and the keyword list of previous options results as its second parameter.
  Passing previous options results is what makes dynamic properties possible.
  This function returns an updated keyword list with the value of the newly
  resolved option:

      iex> XGen.Option.resolve(AnOption, %{previous: "value"})
      Validate the option? (y/n) y
      %{an_option: true, previous: "value"}

  Adding the new value to the keyword list makes possible to chain options. For
  instance, you can use `Enum.reduce/3` to resolve more options:

      iex> Enum.reduce([AnOption, AnotherOption], %{}, &XGen.Option.resolve/2)
      Number of files (1-10): 5
      Confirm? [Y/n]
      %{an_option: 5, another_option: true}
  """

  use XGen.Properties

  alias XGen.Prompt

  @typedoc "A generator option"
  @type t() :: module()

  @typedoc "Option types"
  @type type() :: :string | :integer | :yesno | :choice

  defproperty :key, atom(), doc: "the option key"
  defproperty :type, type(), doc: "the option type"
  defproperty :default, any(), doc: "the default value", optional: true
  defproperty :options, keyword(), doc: "the options", optional: true
  defproperty :name, String.t(), doc: "the option name", optional: true
  defproperty :prompt, String.t(), doc: "the user prompt"

  defproperty :documentation, String.t(),
    doc: "documentation for the option",
    optional: true

  @doc """
  Validates the user input.

  If the value is valid, a validator must return `{:ok, validated_value}`. The
  validated value may be the same as `value` or may be transformed to match a
  given format.

  If the value is invalid, `{:error, message}` must be returned. The message
  will be printed to the user.
  """
  @callback validator(value :: term()) ::
              {:ok, validated_value :: term()}
              | {:error, message :: String.t()}

  @optional_callbacks validator: 1

  @doc false
  defmacro __using__(opts) do
    if opts[:collection] do
      quote do
        import unquote(__MODULE__), only: [defoption: 2]
      end
    else
      quote do
        @behaviour unquote(__MODULE__)
        import unquote(__MODULE__)
      end
    end
  end

  @doc """
  Defines an option.
  """
  defmacro defoption(name, do: block) do
    quote do
      defmodule unquote(name) do
        @moduledoc false

        use unquote(__MODULE__)

        unquote(block)
      end
    end
  end

  @doc """
  Resolves an `option` given some previous results as `opts`.

  To resolve a list of option, you can use this function in conjonction with
  `Enum.reduce/3`:

      iex> Enum.reduce([AnOption, AnotherOption], %{}, &XGen.Option.resolve/2)
      Value: some value
      Number of things (1-10): 7
      %{an_option: "some value", another_option: 7}
  """
  @spec resolve(t(), map()) :: map()
  def resolve(option, opts) do
    properties = option.__info__(:functions)

    key = option.key(opts)
    type = option.type(opts)
    prompt = option.prompt(opts)
    default = if {:default, 1} in properties, do: option.default(opts)
    options = if {:options, 1} in properties, do: option.options(opts), else: []
    validator = if {:validator, 1} in properties, do: &option.validator/1

    if {:name, 1} in properties and {:documentation, 1} in properties do
      Prompt.doc(option.name(opts), option.documentation(opts))
    end

    value = get_value(prompt, type, default, validator, options)

    # Yes/no question can lead to more options being resolved.
    if type == :yesno and value and is_list(options[:if_yes]) do
      opts
      |> Map.merge(Enum.reduce(options[:if_yes], %{}, &resolve/2))
      |> Map.put(key, value)
    else
      Map.put(opts, key, value)
    end
  end

  @spec get_value(String.t(), type(), term(), function(), keyword()) :: term()
  defp get_value(prompt, type, default, validator, opts) do
    type
    |> case do
      :string -> Prompt.prompt(prompt, [default: default] ++ opts)
      :integer -> Prompt.prompt_integer(prompt, [default: default] ++ opts)
      :yesno -> Prompt.yes?(prompt, default)
      :choice -> Prompt.choose(prompt, opts[:choices], default)
    end
    |> validate(validator)
    |> case do
      {:ok, value} ->
        value

      {:error, message} ->
        Prompt.error(message <> "\n")
        get_value(prompt, type, default, validator, opts)
    end
  end

  @spec validate(term(), function()) :: {:ok, term()} | {:error, String.t()}
  defp validate(value, nil), do: {:ok, value}
  defp validate(value, validator), do: validator.(value)
end
