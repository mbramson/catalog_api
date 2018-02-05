defmodule CatalogApi do

  def base_url do
    username = Application.get_env(:catalog_api, :username)
    environment = Application.get_env(:catalog_api, :environment)
    "https://#{username}.#{environment}.catalogapi.com/v1/rest/"
  end
end
