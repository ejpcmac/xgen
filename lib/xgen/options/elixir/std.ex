defmodule XGen.Options.Elixir.Std do
  @moduledoc false

  use XGen.Option, collection: true

  defoption Release do
    defoption ConfigProvider do
      key :config_provider
      type :choice
      default :toml
      options choices: config_providers()
      name "Distillery “Config Providers”"
      prompt "Which Config Provider do you want to use?"

      documentation """
      You may need to configure your application after it has been compiled,
      when deploying your OTP release. Distillery comes with a configuration
      framework called “Config Providers”. xgen can generate a template for you
      using different config providers.
      """

      defp config_providers do
        [
          toml: "Toml.Provider",
          mix: "Distillery.Releases.Config.Providers.Elixir",
          nil: "Do not use a Config Provider"
        ]
      end
    end

    key :release?
    type :yesno
    default :no
    options if_yes: [ConfigProvider]
    name "Release"
    prompt "Generate a release configuration?"

    documentation """
    xgen can add Distillery to your project and generate a standard release
    configuration in rel/config.exs.
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
