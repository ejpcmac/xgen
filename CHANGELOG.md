# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic
Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.7] - 2018-12-13

### Changed

* [elixir_*] Remove `sudo: false` from the Travis CI configuration.

### Fixed

* [nerves] Make the generator work.

## [0.3.6] - 2018-11-16

### Changed

* Update Credo to `1.0.0` 🎉.

## [0.3.5] - 2018-11-16

### Added

* [*] Add an option to add CI configuration.

### Changed

* [elixir_*] Set the Dialyxir version to `1.0-rc`.

### Fixed

* [elixir_std] Fix an assing misspelling in the `mix.exs`.

## [0.3.4] - 2018-11-07

### Changed

* Use the `:test` env for `mix test.watch`.
* [elixir_*] Fix the `config.exs` template.

## [0.3.3] - 2018-11-07

### Added

* [update] Add a `--dev` switch to use the development version.

### Changed

* [elixir_*] Use a custom env for docs.

## [0.3.2] - 2018-11-01

### Added

* [elixir_std] Add config providers for Distillery.

### Changed

* [*] Add the Git revision to development versions.
* [escript] Use Marcus from Hex

## [0.3.1] - 2018-10-13

### Changed

* Additional options are now declared using `if_*`, and there is `if_no` for
    yes/no questions.

### Fixed

* [update] Make it work.

## [0.3.0] - 2018-10-13

### Added

* [*] Add a `shell.nix` and `.envrc` to all generated projects.
* [escript] Add an escript generator.

### Changed

* **BREAKING**: Rename to `xgen`.
* **BREAKING**: xgen is now an interactive escript and no longer a Mix task.
* Update the dependencies.
* Huge refactoring to achive more modularity and extensivity.
* [*] Add workflow preferences for the contributing guidelines.
* [nerves] Update to Nerves 1.3.
* [nerves] Add specific contributing guidelines.

## [0.2.9] - 2018-08-16

### Changed

* Update the dependencies.
* [std] Bump Elixir version to 1.7.

## [0.2.8] - 2018-07-18

### Changed

* [std] Put `distillery` in a new “Release dependencies” section.

## [0.2.7] - 2018-07-07

### Changed

* [std] Remove the `:maintainers` package field.
* [nerves] Upgrade `shoehorn` to v0.3.0.

## [0.2.6] - 2018-07-01

### Changed

* [std] Make Credo and Dialyxir dev-only dependencies.
* [nerves] Bump the Nerves system version to `~> 1.2`.

## [0.2.5] - 2018-06-19

### Changed

* Rework the `.gitignore`.
* Declare templates as `@external_resources`.
* Add a work in progress disclaimer in the default `README.md`.
* Update the dependencies.

## [0.2.4] - 2018-05-27

### Changed

* [std] Update `credo` to v0.9.2.
* [nerves] Update `nerves` to v1.0.
* [nerves] Use `1.1.1.1` instead of Google DNS.

## [0.2.3] - 2018-04-20

### Changed

* [nerves] Put the IEx console on UART instead of HDMI.

## [0.2.2] - 2018-03-24

### Added

* [nerves] Add NTP optional support.
* [nerves] Add DS3231 RTC optional support.
* [nerves] Add optional support for firmware pushes through SSH.
* [nerves] Add optional support for an IEx session via SSH.

### Changed

* [nerves] Update `nerves_runtime`.
* [nerves] Get default WLAN SSID and PSK from system environment.

## [0.2.1] - 2018-03-15

### Fixed

* [nerves] Update `nerves_network` to v0.3.7-rc to fix the static Wi-Fi config.

## [0.2.0] - 2018-03-12

### Added

* [xgen.nerves] Add a Nerves project generator.
* [xgen.std] Add an option to add Distillery to the project.
* [xgen.std] Add an opt-out for Git repo initialisation.

### Changed

* Code refactoring.

### Fixed

* [xgen.\*] Do not put the Hex version in the `README.md` if `--package` is not
  set.

## [0.1.2] - 2018-02-27

### Removed

* Remove useless TODO in the `/TODO`.

### Fixed

* Make the generated `.gitsetup` executable.

## [0.1.1] - 2018-02-22

### Added

* Add a `local.xgen` Mix task to update ExGen locally.
* Provide documentation for installing from the precompiled archive.

## [0.1.0] - 2018-02-21

### Added

* Generator for a standard project with dependencies and a Git repo.
* Option to add a `CONTRIBUTING.md`.
* Option to add package information.
* Option to add a license.
* Option to add a TODO.

[Unreleased]: https://github.com/ejpcmac/xgen/compare/master...develop
[0.3.7]: https://github.com/ejpcmac/xgen/compare/v0.3.6...v0.3.7
[0.3.6]: https://github.com/ejpcmac/xgen/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/ejpcmac/xgen/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/ejpcmac/xgen/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/ejpcmac/xgen/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/ejpcmac/xgen/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/ejpcmac/xgen/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/ejpcmac/xgen/compare/v0.2.9...v0.3.0
[0.2.9]: https://github.com/ejpcmac/xgen/compare/v0.2.8...v0.2.9
[0.2.8]: https://github.com/ejpcmac/xgen/compare/v0.2.7...v0.2.8
[0.2.7]: https://github.com/ejpcmac/xgen/compare/v0.2.6...v0.2.7
[0.2.6]: https://github.com/ejpcmac/xgen/compare/v0.2.5...v0.2.6
[0.2.5]: https://github.com/ejpcmac/xgen/compare/v0.2.4...v0.2.5
[0.2.4]: https://github.com/ejpcmac/xgen/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/ejpcmac/xgen/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/ejpcmac/xgen/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/ejpcmac/xgen/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/ejpcmac/xgen/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/ejpcmac/xgen/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/ejpcmac/xgen/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/ejpcmac/xgen/releases/tag/v0.1.0
