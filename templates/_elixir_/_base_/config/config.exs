import Config

if config_env() == :test do
  # Clear the console before each test run.
  config :mix_test_watch, clear: true
end
