defmodule XGen.Wizards.ConfigCreator do
  @moduledoc """
  A wizard for initial configuration creation.
  """

  @spec run :: :ok | no_return()
  @spec run(keyword()) :: :ok | no_return()
  def run(opts \\ []) do
    Mix.shell().info("""
    No configuration has been found. Please enter some information about you as
    asked below. It will be used to automatically put you name and GitHub
    account where they belong in generated projects.
    """)

    config = [
      name: ask_name(),
      github_account: ask_github_account()
    ]

    file = opts[:file] || XGen.user_home() |> Path.join(".xgen.exs")

    case File.write(file, Macro.to_string(quote(do: unquote(config)))) do
      :ok ->
        Mix.shell().info("""

        Your initial configuration has been successfully written to #{file}.
        You can edit this file to update your configuration as needed.
        """)

      {:error, reason} ->
        Mix.shell().info([
          :red,
          "\nAn error has occured while writing to #{file}: #{reason}",
          :reset
        ])

        System.halt(1)
    end
  end

  defp ask_name do
    case "Full name:" |> Mix.shell().prompt() |> String.trim() do
      "" -> ask_name()
      name -> name
    end
  end

  defp ask_github_account do
    case "GitHub account:" |> Mix.shell().prompt() |> String.trim() do
      "" -> ask_github_account()
      account -> account
    end
  end
end
