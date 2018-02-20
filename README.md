# ExGen

An opinionated Elixir project generator.

## Features

Each new project comes with the following dependencies:

* `credo`
* `dialyxir`
* `excoveralls`
* `mix_test_watch`
* `ex_unit_notifier`
* `stream_data`
* `ex_doc`

You can choose to add package information, a license, and a `CONTRIBUTING.md` to
your project.

## Setup

1. Clone this repository

        $ git clone https://github.com/ejpcmac/ex_gen.git

2. Build and install the archive:

        $ MIX_ENV=prod mix archive.install

3. Generate a configuration file

        $ mix xgen.config.create
        Full name: <your name>
        GitHub account: <your account>

## Usage

    $ mix xgen.std <path> [--app <app>] [--module <module>] [--sup] [--contrib]
                          [--package] [--license <license>] [--todo]
                          [--config <file>]

A project will be create at the given `<path>`. The application and module
names will be inferred from the path, unless you specify them using the
`--app` and `--module` options.

## Options

* `--app <app>`: set the OTP application name for the project.

* `--module <module>`: set the module name for the project.

* `--sup`: add an `Application` module to the project containing a supervision
    tree. This option also adds the callback in the `mix.exs`.

* `--contrib`: add a `CONTRIBUTING.md` to the project.

* `--package`: add package information in the `mix.exs`.

* `--license <license>`: set the license for the project. If the `--package`
    option is set, the license is precised in the package information. If the
    license is supported, a `LICENSE` file is created with the maintainer
    name.

* `--todo`: add a `TODO` file to the project. This file is also added to the
    Git excluded files in `.git/info/exclude`.

* `--config <file>`: indicate which configuration file to use. Defaults to
    `~/.xgen.exs`

## Supported licenses

Currently, only the `MIT` license is supported.

## Roadmap

In the future, this generator will be able to generate more complex project,
like Phoenix applications with a full-featured user management to kickstart
development, or Nerves applications too. That mainly depends on my needs and the
time I have.

## [Contributing](CONTRIBUTING.md)

Before contributing to this project, please read the
[CONTRIBUTING.md](CONTRIBUTING.md).

## License

Copyright © 2018 Jean-Philippe Cugnet

This project is licensed under the [MIT license](LICENSE).

Some code have been inspired by the Mix, Phoenix and Nerves generators.
