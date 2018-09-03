[
  inputs: [
    "{mix,.iex,.formatter,.credo}.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  line_length: 80,
  import_deps: [:typed_struct],
  locals_without_parens: [
    defproperty: 2,
    defproperty: 3
  ]
]
