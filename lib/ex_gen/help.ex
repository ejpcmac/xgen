defmodule ExGen.Help do
  @moduledoc false

  @doc false
  @spec general_description :: String.t()
  def general_description do
    """
    A project will be created at the given `<path>`. The application and module
    names will be inferred from the path, unless you specify them using the
    `--app` and `--module` options.
    """
  end

  @doc false
  @spec app :: String.t()
  def app do
    "`--app <app>`: set the OTP application name for the project."
  end

  @doc false
  @spec module :: String.t()
  def module do
    "`--module <module>`: set the module name for the project."
  end

  @doc false
  @spec sup :: String.t()
  def sup do
    """
    `--sup`: add an `Application` module to the project containing a supervision
    tree. This option also adds the callback in `mix.exs`.
    """
  end

  @doc false
  @spec contrib :: String.t()
  def contrib do
    "`--contrib`: add a `CONTRIBUTING.md` to the project."
  end

  @doc false
  @spec license :: String.t()
  def license do
    """
    `--license <license>`: set the license for the project. If the license is
    supported, a `LICENSE` file is created with the maintainer’s name.
    """
  end

  @doc false
  @spec todo :: String.t()
  def todo do
    """
    `--todo`: add a `TODO` file to the project. This file is also added to the
    Git excluded files in `.git/info/exclude`.
    """
  end

  @doc false
  @spec no_git :: String.t()
  def no_git do
    "`--no-git`: do not initialise a Git repository."
  end

  @doc false
  @spec config :: String.t()
  def config do
    """
    `--config <file>`: indicate which configuration file to use. Defaults to
    `~/.xgen.exs`
    """
  end

  @doc false
  @spec supported_licences :: String.t()
  def supported_licences do
    """
    ## Supported licenses

    Currently, only the `MIT` license is supported.
    """
  end
end
