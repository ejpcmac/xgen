defmodule XGen.Wizards.LicenseChooser do
  @moduledoc """
  A wizard to help choose a license.
  """

  use XGen.Wizard

  @licenses [
    mit: "MIT License"
  ]

  @license_codes [
    mit: "MIT"
  ]

  @impl true
  @spec run :: String.t() | nil
  @spec run(keyword()) :: String.t() | nil
  def run(_opts \\ []) do
    if yes?("Add a license?", false) do
      key = choose("Which license to add?", @licenses)
      Keyword.get(@license_codes, key)
    end
  end
end
