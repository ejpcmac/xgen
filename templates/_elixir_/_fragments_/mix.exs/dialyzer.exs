# Dialyzer configuration
defp dialyzer do
  [
    plt_add_deps: :transitive,
    flags: [
      :unmatched_returns,
      :error_handling,
      :race_conditions
    ],
    ignore_warnings: ".dialyzer_ignore"
  ]
end
