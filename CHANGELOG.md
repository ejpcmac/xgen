# Changelog

## v0.3.2

### New features

* [elixir_std] Add config providers for Distillery

### Enhancements

* [*] Add the Git revision to development versions
* [escript] Use Marcus from Hex

## v0.3.1

### Enhancements

* Additional options are now declared using `if_*`, and there is `if_no` for
    yes/no questions

### Bug fixes

* [update] Make it work

## v0.3.0

### Breaking changes

* Rename to `xgen`
* xgen is now an interactive escript and no longer a Mix task

### New features

* [*] Add a `shell.nix` and `.envrc` to all generated projects
* [escript] Add an escript generator

### Enhancements

* Update dependencies
* Huge refactoring to achive more modularity and extensivity
* [*] Add workflow preferences for the contributing guidelines
* [nerves] Update to Nerves 1.3
* [nerves] Add specific contributing guidelines

## v0.2.9

### Enhancements

* Update dependencies
* [std] Bump Elixir version to 1.7

## v0.2.8

### Enhancements

* [std] Put `distillery` in a new “Release dependencies” section

## v0.2.7

### Enhancements

* [std] Remove the `:maintainers` package field
* [nerves] Upgrade `shoehorn` to v0.3.0

## v0.2.6

### Enhancements

* [std] Make Credo and Dialyxir dev-only dependencies
* [nerves] Bump the Nerves system version to `~> 1.2`

## v0.2.5

### Enhancements

* Rework the `.gitignore`
* Declare templates as `@external_resources`
* Add a work in progress disclaimer in the default `README.md`
* Update dependencies

## v0.2.4

### Enhancements

* [std] Update `credo` to v0.9.2
* [nerves] Update `nerves` to v1.0
* [nerves] Use `1.1.1.1` instead of Google DNS

## v0.2.3

* [nerves] Put the IEx console on UART instead of HDMI

## v0.2.2

### New features

* [nerves] Add NTP optional support
* [nerves] Add DS3231 RTC optional support
* [nerves] Add optional support for firmware pushes through SSH
* [nerves] Add optional support for an IEx session via SSH

### Enhancements

* [nerves] Update `nerves_runtime`
* [nerves] Get default WLAN SSID and PSK from system environment

## v0.2.1

* [nerves] Update `nerves_network` to v0.3.7-rc to fix the static Wi-Fi config

## v0.2.0

### New features

* [xgen.nerves] Add a Nerves project generator
* [xgen.std] Add an option to add Distillery to the project
* [xgen.std] Add an opt-out for Git repo initialisation

### Enhancements

* Code refactoring

### Bug fixes

* [xgen.\*] Do not put the Hex version in the `README.md` if `--package` is not
  set

## v0.1.2

* Make the generated `.gitsetup` executable
* Remove useless TODO in the `/TODO`

## v0.1.1

* Add a `local.xgen` Mix task to update ExGen locally
* Provide documentation for installing from the precompiled archive

## v0.1.0

* Generator for a standard project with dependencies and a Git repo
* Option to add a `CONTRIBUTING.md`
* Option to add package information
* Option to add a license
* Option to add a TODO
