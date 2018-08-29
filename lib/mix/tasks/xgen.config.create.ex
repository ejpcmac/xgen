defmodule Mix.Tasks.Xgen.Config.Create do
  use Mix.Task

  @shortdoc "Generates a configuration file for xgen"

  @moduledoc """
  Generates a configuration file for xgen.
  """

  @impl true
  def run(_args) do
    config = [
      name: ask_name(),
      github_account: ask_github_account()
    ]

    System.user_home!()
    |> Path.join(".xgen.exs")
    |> File.write!(Macro.to_string(quote(do: unquote(config))))
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
