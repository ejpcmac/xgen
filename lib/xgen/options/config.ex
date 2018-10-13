defmodule XGen.Options.Config do
  @moduledoc false

  use XGen.Option, collection: true

  defoption Name do
    key :name
    type :string
    default @name
    options required: true
    prompt "Full name"
  end

  defoption GitHubAccount do
    key :github_account
    type :string
    default @github_account
    options required: true
    prompt "GitHub account"
  end
end
