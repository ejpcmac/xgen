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
    if license?() do
      key = choose("\nWhich license do you want to add?", @licenses)
      info("")

      Keyword.get(@license_codes, key)
    end
  end

  defp license? do
    doc(
      "License",
      """
      If you plan to distribute your project, it may be good to add a license.
      xgen can generate the LICENSE file for you, automatically using your name
      and the current year in the copyright line if appropriate. If you choose
      to add a license, a prompt will ask you to choose between a few available.
      """
    )

    yes?("Add a license?", false)
  end
end
