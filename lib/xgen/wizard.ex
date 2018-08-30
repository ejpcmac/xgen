defmodule XGen.Wizard do
  @moduledoc """
  Helpers to create wizards for project generation.
  """

  alias IO.ANSI

  @doc """
  Runs the wizard.
  """
  @callback run(opts :: keyword()) :: term() | no_return()

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
  """
  @spec prompt(String.t()) :: String.t()
  def prompt(message) do
    (message <> " ") |> IO.gets() |> String.trim()
  end

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

    index = list |> length() |> get_choice()

    list
    |> Enum.at(index - 1)
    |> elem(0)
  end

  @spec get_choice(pos_integer()) :: pos_integer()
  defp get_choice(max) do
    with entry when entry != "" <- prompt("\nChoice:"),
         {choice, _} when choice in 1..max <- Integer.parse(entry) do
      choice
    else
      "" ->
        error("You must make a choice!")
        get_choice(max)

      _ ->
        error("The choice must be an integer between 1 and #{max}.")
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
