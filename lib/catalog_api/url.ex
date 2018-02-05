defmodule CatalogApi.Url do
  alias CatalogApi.Credentials

  def credential_params(method) do
    method
    |> Credentials.creds_for_request
    |> URI.encode_query
  end

  def base_url do
    username = Application.get_env(:catalog_api, :username)
    environment = Application.get_env(:catalog_api, :environment)
   "https://#{username}.#{environment}.catalogapi.com/v1/rest/"
  end
end
