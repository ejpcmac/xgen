set config_providers: [
      {Toml.Provider, path: "${RELEASE_ROOT_DIR}/etc/config.toml"}
    ]

set overlays: [
      {:copy, "rel/config/defaults.toml", "etc/config.toml.sample"}
    ]
