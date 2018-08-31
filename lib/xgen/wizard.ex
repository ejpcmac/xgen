defmodule XGen.Wizard do
  @moduledoc """
  Helpers to create wizards for project generation.
  """

  alias IO.ANSI

  @doc """
  Runs the wizard.
  """
  @callback run(opts :: keyword()) :: term() | no_return()

  @typedoc "Answer to a yes-no question"
  @type yesno() :: :yes | :no | nil

  @yes ~w(y Y yes YES Yes)
  @no ~w(n N no NO No)

  defmacro __using__(_opts) do
    quote do
      @behaviour XGen.Wizard
      import XGen.Wizard
    end
  end

  @doc """
  Prints the given ANSI-formatted `message`.
  """
  @spec info(ANSI.ansidata()) :: :ok
  def info(message) do
    message |> ANSI.format() |> IO.puts()
  end

  @doc """
  Prints the given ANSI-formatted `message` in green.
  """
  @spec green_info(ANSI.ansidata()) :: :ok
  def green_info(message) do
    info([:green, message])
  end

  @doc """
  Prints documentation with a `title` and `content`.
  """
  @spec doc(String.t(), ANSI.ansidata()) :: :ok
  def doc(title, content) do
    info([:blue, :bright, "\n  #{title}\n\n", :normal, content])
  end

  @doc """
  Prints the given ANSI-formatted error `message` on `:stderr`.
  """
  @spec error(ANSI.ansidata()) :: :ok
  def error(message) do
    IO.puts(:stderr, ANSI.format([:red, :bright, message]))
  end

  @doc """
  Prints the given ANSI-formatter error an exits with an error status.
  """
  @spec halt(ANSI.ansidata()) :: no_return()
  @spec halt(ANSI.ansidata(), non_neg_integer()) :: no_return()
  def halt(message, status \\ 1) do
    error(message)
    System.halt(status)
  end

  @doc """
  Prints the given `message` and prompts a user for input.

  The result string is trimmed.

  ## Options

    * `default` - default value for empty replies (printed in the prompt if set)
    * `mandatory` - wether a non-empty input is mandatory (default: `false`)
    * `error_message` - the message to print if a mandatory input is missing
  """
  @spec prompt(String.t()) :: String.t()
  @spec prompt(String.t(), keyword()) :: String.t()
  def prompt(message, opts \\ []) do
    (message <> format_prompt(opts[:default]))
    |> IO.gets()
    |> String.trim()
    |> parse_response(opts[:default], !!opts[:mandatory])
    |> case do
      nil ->
        error_message = opts[:error_message] || "You must provide a value!"
        error(error_message <> "\n")
        prompt(message, opts)

      value ->
        value
    end
  end

  @spec format_prompt(String.t() | nil) :: String.t()
  defp format_prompt(nil), do: ": "
  defp format_prompt(default), do: " [#{default}]: "

  @spec parse_response(String.t(), String.t() | nil, boolean()) ::
          String.t() | nil
  defp parse_response("", nil, true), do: nil
  defp parse_response("", default, _) when not is_nil(default), do: default
  defp parse_response(value, _default, _), do: value

  @doc """
  Asks the user a yes-no `question`.

  If there is no default value, the user must type an answer. Otherwise hitting
  enter chooses the default answer.
  """
  @spec yes?(String.t()) :: boolean()
  @spec yes?(String.t(), yesno()) :: boolean()
  def yes?(message, default \\ nil) when default in [:yes, :no, nil] do
    (message <> format_yesno(default))
    |> IO.gets()
    |> String.trim()
    |> parse_yesno(default)
    |> case do
      nil ->
        error("You must answer yes or no.\n")
        yes?(message, default)

      answer ->
        answer == :yes
    end
  end

  @spec format_yesno(yesno()) :: String.t()
  defp format_yesno(:yes), do: " [Y/n] "
  defp format_yesno(:no), do: " [y/N] "
  defp format_yesno(nil), do: " (y/n) "

  @spec parse_yesno(String.t(), yesno()) :: yesno()
  defp parse_yesno(value, _default) when value in @yes, do: :yes
  defp parse_yesno(value, _default) when value in @no, do: :no
  defp parse_yesno("", default), do: default
  defp parse_yesno(_, _default), do: nil

  @doc """
  Asks the user to choose between a list of elements.

  The given `list` must be a keyword list. The values will be printed and the
  key of the chosen one returned.
  """
  @spec choose(String.t(), keyword()) :: atom()
  def choose(message, list) do
    info(message <> "\n")

    list
    |> Keyword.values()
    |> Enum.with_index(1)
    |> Enum.each(fn {elem, i} -> IO.puts("  #{i}. #{elem}") end)

    info("")
    index = list |> length() |> get_choice()

    list
    |> Enum.at(index - 1)
    |> elem(0)
  end

  @spec get_choice(pos_integer()) :: pos_integer()
  defp get_choice(max) do
    "Choice"
    |> prompt(mandatory: true, error_message: "You must make a choice!")
    |> Integer.parse()
    |> case do
      {choice, _} when choice in 1..max ->
        choice

      _ ->
        error("The choice must be an integer between 1 and #{max}.\n")
        get_choice(max)
    end
  end

  @doc """
  Returns the user’s home or exits with an error.
  """
  @spec user_home :: String.t() | no_return()
  def user_home do
    case System.user_home() do
      nil -> error("Error: the current user has no home directory!")
      home -> home
    end
  end
end
