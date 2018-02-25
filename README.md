# CatalogApi

[![Travis CI](https://travis-ci.org/mbramson/catalog_api.svg?branch=master)](https://travis-ci.org/mbramson/catalog_api)

CatalogApi is a library that can be used to make interacting with the
catalogapi.com API more straightforward in elixir.

**Note: this library is very far from stable at the moment. Once it hits 1.0 it
will be stable as per standard semantic versioning practices. Until that point,
use at your own risk.**

## Installation

CatalogApi can be installed by adding `catalog_api` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:catalog_api, "~> 0.0.4"}
  ]
end
```

You will have to set a few values in the config.exs file of applications which consume this library.
- `secret_key`: The secret key that was given to you by CatalogApi. This should
  be available at http://<username>.catalogapi.com/stats/ where <username> is
  whatever username supplied by CatalogApi.
- `username`: The username that was supplied to you by CatalogApi. This is the
  username of your site itself, not your specific login credential.
- `environment`: This can be "dev" or "prod", and corresponds to which endpoint
  should be hit. See http://<username>.catalogapi.com/docs/environments/ for
  more documentation.

An example config.exs entry for a development environment might look like:
```elixir
config :catalog_api,
  secret_key: "ABC1234567890",
  username: "company_name",
  environment: "dev"
```

Documentation can be found on hexdocs at
[https://hexdocs.pm/catalog_api](https://hexdocs.pm/catalog_api).
