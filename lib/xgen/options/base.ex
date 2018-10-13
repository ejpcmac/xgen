defmodule XGen.Options.Base do
  @moduledoc false

  use XGen.Option, collection: true

  defoption Path do
    import Marcus

    key :path
    type :string
    options required: true
    prompt "Project directory"

    @impl true
    @spec validator(String.t()) :: {:ok, String.t()} | {:error, String.t()}
    def validator(path) do
      msg =
        "\nThe directory #{inspect(path)} already exists. Are you sure you " <>
          "want to continue?"

      # Abort the project creation if the answer is no.
      if File.dir?(path) and not yes?(msg, default: :no) do
        System.halt()
      end

      {:ok, path}
    end
  end

  defoption Contributing do
    defoption CloneType do
      defoption GitRepo do
        key :git_repo
        type :string
        options required: true
        prompt "Git repository"
      end

      key :clone_type
      type :choice
      default :github_fork
      options choices: clone_types(), repo_clone: [GitRepo]

      prompt "\nWhich kind of workflow do you want for setting up the local " <>
               "repo?"

      defp clone_types do
        [
          github_fork:
            "Do a fork on GitHub, then clone and add an upstream remote",
          repo_clone: "Clone the repository directly"
        ]
      end
    end

    defoption Workflow do
      key :workflow
      type :choice
      default :external
      options choices: workflows()
      prompt "\nWhich kind of branching workflow do you want to follow?"

      defp workflows do
        [
          external: "GitHub-style contributing workflow with git-flow"
        ]
      end
    end

    key :contributing?
    type :yesno
    default :no
    options yes: [CloneType, Workflow]
    name "CONTRIBUTING.md"
    prompt "Add a CONTRIBUTING.md?"

    documentation """
    xgen can add a CONTRIBUTING.md with instructions covering the setup for
    the local repository, the development environment, the workflow and style
    guide. You will be asked some questions to customise its content.
    """
  end

  defoption License do
    defoption LicenseChoice do
      key :license
      type :choice
      options choices: licenses()
      prompt "\nWhich license do you want to add?"

      defp licenses do
        [
          MIT: "MIT License"
        ]
      end
    end

    key :license?
    type :yesno
    default :no
    options yes: [LicenseChoice]
    name "License"
    prompt "Add a license?"

    documentation """
    If you plan to distribute your project, it may be good to add a license.
    xgen can generate the LICENSE file for you, automatically using your name
    and the current year in the copyright line if appropriate. If you choose to
    add a license, a prompt will ask you to choose between a few available.
    """
  end

  defoption Git do
    key :git?
    type :yesno
    default :yes
    prompt "Initialise a Git repository?"
  end
end
