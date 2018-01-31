# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# Note: the secret key specified below only applies when using this client
# locally as a standalone mix project. When using this client as a dependency
# for another project, you will need to specify this config in that project's
# config.exs file.

config :catalog_api, secret_key: System.get_env("CATALOG_API_SECRET_KEY")
