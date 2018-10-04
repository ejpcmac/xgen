defmodule XGen.Options.Elixir.Std do
  @moduledoc false

  use XGen.Option, collection: true

  defoption Release do
    key :release?
    type :yesno
    default :no
    name "Release"
    prompt "Generate a release configuration?"

    documentation """
    xgen can add Distillery to your project and generate a standard release
    configuration in rel/config.exs.
    """
  end

  defoption Contributing do
    key :contributing?
    type :yesno
    default :no
    name "CONTRIBUTING.md"
    prompt "Add a CONTRIBUTING.md?"

    documentation """
    xgen can add a CONTRIBUTING.md with generic instructions for Elixir projects
    hosted on GitHub. It covers all steps from forking to setting the
    environment and creating a pull request.
    """
  end

  defoption Package do
    key :package?
    type :yesno
    default :no
    name "Package information"
    prompt "Add package information?"

    documentation """
    If you are writing an Elixir library, you may want to publish it with Hex.
    In this case, xgen can add package information to the mix.exs so you don’t
    have to write it afterwards.
    """
  end
end
