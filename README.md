# xgen

[![Build Status](https://travis-ci.com/ejpcmac/xgen.svg?branch=develop)](https://travis-ci.com/ejpcmac/xgen)

`xgen` is an opinionated interactive project generator. It can currently
generate standard Elixir, Nerves and escript projects. The documentation for
options is printed directly during the generation process, so that you don’t
need to remember all the possibilities if you don’t use it every day.

## Features

Each project comes with:

* a `README.md` template;
* a `CHANGELOG.md` with the initial version;
* a `.editorconfig`;
* a `shell.nix` and `.envrc` to set up reliably the development environment
    using [Nix](https://nixos.org/nix/), and optionally
    [direnv](https://github.com/direnv/direnv);
* an optional license file.

If Git is enabled, a `.gitsetup` script is also added to the project to help
setting `git-flow` the same way on every machine.

### Standard Elixir projects

Each new standard Elixir project comes with the following dependencies:

* [`credo`](https://github.com/rrrene/credo)
* [`dialyxir`](https://github.com/jeremyjh/dialyxir)
* [`excoveralls`](https://github.com/parroty/excoveralls)
* [`mix_test_watch`](https://github.com/lpil/mix-test.watch)
* [`ex_unit_notifier`](https://github.com/navinpeiris/ex_unit_notifier)
* [`stream_data`](https://github.com/whatyouhide/stream_data)
* [`ex_doc`](https://github.com/elixir-lang/ex_doc)

In addition to the common options, you can choose to add a supervision tree, a
release configuration with Distillery, package information, and a
`CONTRIBUTING.md` to your project.

### Nerves projects

Nerves project are already configured with a release and the IEx console on
UART. In addition to the options available in standard projects, you can add a
network configuration that works out of the box, setup SSH firmware updates, NTP
and more.

### Elixir escripts

escript projects comes with the standard Elixir projects dependencies, and:

* [`ex_cli`](https://github.com/danhper/ex_cli)
* [`marcus`](https://github.com/ejpcmac/marcus)

A “Hello, World!” escript is generated as an example.

## Installation

To install `xgen`:

    $ mix escript.install github ejpcmac/xgen

To update an already installed `xgen`:

    $ xgen update

To update to the current development version:

    $ xgen update --dev

## Usage

Once installed, simply run:

    $ xgen

You will asked to choose the type of project you want to generate and guided
through the process.

## Roadmap

* [x] Standard Elixir projects generator
* [x] Nerves projects generator
* [x] Interactive generation
* [x] Declarative way of handling generators and options
* [x] escript generation
* [ ] Minimal Phoenix projects generation
* [ ] C projects generation (with Nix and Ceedling configured)
* [ ] Exctraction of the generation logic\*
* [ ] Project generator generation (for fun!)

\* I eventually plan to extract all the generation logic in a project generator
framework and only keep generators, options and templates in `xgen`. This way,
anyone will be able to build easily a project generator fitting its own needs.
`xgen` will provide a project generator generator as a beautiful *mise en
abyme*.

## [Contributing](CONTRIBUTING.md)

Before contributing to this project, please read the
[CONTRIBUTING.md](CONTRIBUTING.md).

## License

Copyright © 2018, 2020 Jean-Philippe Cugnet

This project is licensed under the [MIT license](LICENSE).

Some code have been inspired by Mix, Phoenix and Nerves generators.
