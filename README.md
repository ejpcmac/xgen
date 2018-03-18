# ExGen

An opinionated Elixir multi-project generator.

## Features

ExGen can currently generate standard or Nerves projects.

### Standard projects

Each new project comes with the following dependencies:

* `credo`
* `dialyxir`
* `excoveralls`
* `mix_test_watch`
* `ex_unit_notifier`
* `stream_data`
* `ex_doc`

You can choose to add a supervision tree, Distillery, package information, a
license, and a `CONTRIBUTING.md` to your project. A Git repository is
automatically initialised, with an opt-out switch if you don’t need it.

### Nerves projects

Nerves project are already configured with a release. In addition to the options
available in a standard project, you can add a network configuration that works
out of the box.

## Installation

### From archive

You can install ExGen directly from a compiled archive:

    $ mix archive.install https://ejpcmac.net/bin/ex_gen.ez

To update an already installed ExGen:

    $ mix local.xgen

### From source

1. Clone this repository

        $ git clone https://github.com/ejpcmac/ex_gen.git

2. Build and install the archive:

        $ MIX_ENV=prod mix archive.install

## Configuration

You will need to generate a configuration file for ExGen to put your name and
the correct GitHub links in the generated projects:

    $ mix xgen.config.create
    Full name: <your name>
    GitHub account: <your account>

## Usage

#### Standard

    $ mix xgen.std <path> [--app <app>] [--module <module>] [--sup] [--rel]
                          [--contrib] [--package] [--license <license>] [--todo]
                          [--no-git] [--config <file>]

#### Nerves

    $ mix xgen.nerves <path> [--app <app>] [--module <module>] [--sup] [--net]
                             [--ntp] [--rtc] [--contrib] [--license <license>]
                             [--todo] [--no-git] [--config <file>]

A project will be created at the given `<path>`. The application and module
names will be inferred from the path, unless you specify them using the
`--app` and `--module` options.

## Options

* `--app <app>`: set the OTP application name for the project.

* `--module <module>`: set the module name for the project.

* `--sup`: add an `Application` module to the project containing a supervision
    tree. This option also adds the callback in `mix.exs`.

* `--rel`: add Distillery to the project with a configuration.

* `--net`: add `nerves_network` to the project with a basic configuration.

* `--ntp`: add `nerves_ntp` to the project.

* `--rtc`: add support for a DS3231 RTC. If the `--sup` option is set, a
    temporary task is generated to set the OS time from the RTC on startup. If
    both `--sup` and `--ntp` are set, a temporary task is generated to sync the
    RTC from OS time 15 seconds after the application startup. This lets some
    time for NTP to sync.

* `--contrib`: add a `CONTRIBUTING.md` to the project.

* `--package`: add package information in `mix.exs`.

* `--license <license>`: set the license for the project. If the license is
    supported, a `LICENSE` file is created with the maintainer name. If the
    `--package` option is set, the license is precised in the package
    information.

* `--todo`: add a `TODO` file to the project. This file is also added to the
    Git excluded files in `.git/info/exclude`.

* `--no-git`: do not initialise a Git repository.

* `--config <file>`: indicate which configuration file to use. Defaults to
    `~/.xgen.exs`

## Supported licenses

Currently, only the `MIT` license is supported.

## Roadmap

In the future, this generator will be able to generate more complex project,
like Phoenix applications with a full-featured user management to kickstart
development. That mainly depends on my needs and the time I have.

## [Contributing](CONTRIBUTING.md)

Before contributing to this project, please read the
[CONTRIBUTING.md](CONTRIBUTING.md).

## License

Copyright © 2018 Jean-Philippe Cugnet

This project is licensed under the [MIT license](LICENSE).

Some code have been inspired by Mix, Phoenix and Nerves generators.
