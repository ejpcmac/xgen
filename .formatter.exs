[
  inputs: [
    "{mix,.iex,.formatter,.credo}.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  line_length: 80,
  import_deps: [:typed_struct],
  locals_without_parens: [
    # Properties
    defproperty: 2,
    defproperty: 3,

    # Options
    key: 1,
    type: 1,
    default: 1,
    name: 1,
    documentation: 1,
    prompt: 1,
    options: 1,

    # Generators
    pregen: 1,
    postgen: 1,
    collection: 1,
    collection: 2
  ]
]
