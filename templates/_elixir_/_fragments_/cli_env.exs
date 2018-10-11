defp cli_env do
  [
    # Always run coveralls mix tasks in `:test` env.
    coveralls: :test,
    "coveralls.detail": :test,
    "coveralls.html": :test
  ]
end
