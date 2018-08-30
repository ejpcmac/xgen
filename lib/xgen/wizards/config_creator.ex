defmodule XGen.Wizards.ConfigCreator do
  @moduledoc """
  A wizard for initial configuration creation.
  """

  use XGen.Wizard

  @impl true
  @spec run :: :ok | no_return()
  @spec run(keyword()) :: :ok | no_return()
  def run(opts \\ []) do
    info("""
    No configuration has been found. Please enter some information about you as
    asked below. It will be used to automatically put you name and GitHub
    account where they belong in generated projects.
    """)

    config = [
      name: ask_name(),
      github_account: ask_github_account()
    ]

    file = opts[:file] || user_home() |> Path.join(".xgen.exs")

    case File.write(file, Macro.to_string(quote(do: unquote(config)))) do
      :ok ->
        green_info("""

        Your initial configuration has been successfully written to #{file}.
        You can edit this file to update your configuration as needed.
        """)

      {:error, reason} ->
        halt("\nAn error has occured while writing to #{file}: #{reason}")
    end
  end

  @spec ask_name :: String.t()
  defp ask_name do
    case prompt("Full name:") do
      "" -> ask_name()
      name -> name
    end
  end

  @spec ask_github_account :: String.t()
  defp ask_github_account do
    case prompt("GitHub account:") do
      "" -> ask_github_account()
      account -> account
    end
  end
end
