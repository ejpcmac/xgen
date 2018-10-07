defmodule XGen.Generator.StandardCallbacks do
  @moduledoc """
  Standard callbacks to use in generators.
  """

  import XGen.Prompt

  @doc """
  Initialises a Git repository and sets correct permissions on the `.gitsetup`
  script if necessary.
  """
  @spec init_git(map()) :: map()
  def init_git(opts) do
    if opts[:git?] do
      green_info("* initializing an empty Git repository")
      _ = System.cmd("git", ["init"])
      File.chmod!(".gitsetup", 0o755)
    end

    opts
  end

  @doc """
  Prints a project created message.
  """
  @spec project_created(map()) :: map()
  def project_created(opts) do
    info([:green, :bright, "\nYour project has been successfully created.\n"])
    opts
  end

  @doc """
  Prints instructions to setup gitflow.
  """
  @spec gitsetup_instructions(map()) :: map()
  def gitsetup_instructions(opts) do
    if opts[:git?] do
      info("""
      After your first commit, you can setup gitflow:

          ./.gitsetup
      """)
    end

    opts
  end
end
