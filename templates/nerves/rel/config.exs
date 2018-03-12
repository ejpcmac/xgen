use Mix.Releases.Config,
  default_release: :<%= @app %>,
  default_environment: Mix.env()

# For a full list of config options for both releases and environments, visit
# https://hexdocs.pm/distillery/configuration.html

environment :dev do
  set cookie:
        :"<%= @cookie %>"
end

environment :prod do
  set cookie:
        :"<%= @cookie %>"
end

# Release for the Nerves system.
release :<%= @app %> do
  set version: current_version(:<%= @app %>)
  plugin Shoehorn

  if System.get_env("NERVES_SYSTEM") do
    set dev_mode: false
    set include_src: false
    set include_erts: System.get_env("ERL_LIB_DIR")
    set include_system_libs: System.get_env("ERL_SYSTEM_LIB_DIR")
    set vm_args: "rel/vm.args"
  end
end
