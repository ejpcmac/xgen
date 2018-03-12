# Changelog

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
