[
  inputs: [
    "{mix,.iex,.formatter,.credo}.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  line_length: 80,
  locals_without_parens: [
    # Distillery
    plugin: 1,
    set: 1
  ]
]