# <%= @mod %>

[![hex.pm version](http://img.shields.io/hexpm/v/<%= @app %>.svg?style=flat)](https://hex.pm/packages/<%= @app %>)

**TODO: Add description**<%= if @contrib do %>

## [Contributing](CONTRIBUTING.md)

Before contributing to this project, please read the
[CONTRIBUTING.md](CONTRIBUTING.md).<% end %><%= if @license == "MIT" do %>

## License

Copyright © <%= DateTime.utc_now().year %> <%= @maintainer %>

This project is licensed under the [MIT license](LICENSE).<% end %>
