[
  inputs: [
    "{mix,.iex,.formatter,.credo}.exs",
    "{config,lib,rel,test}/**/*.{ex,exs}"
  ],
  line_length: 80,
  import_deps: [:ex_cli, :typed_struct],
  locals_without_parens: [
    # Properties
    defproperty: 2,
    defproperty: 3,

    # Generators and options
    collection: 1,
    collection: 2,
    default: 1,
    documentation: 1,
    key: 1,
    name: 1,
    options: 1,
    overrides: 1,
    postgen: 1,
    prompt: 1,
    type: 1,

    # Templates
    set: 1
  ]
]
