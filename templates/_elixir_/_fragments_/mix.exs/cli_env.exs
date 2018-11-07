defp cli_env do
  [
    # Always run Coveralls Mix tasks in `:test` env.
    coveralls: :test,
    "coveralls.detail": :test,
    "coveralls.html": :test,

    # Use a custom env for docs.
    docs: :docs
  ]
end
