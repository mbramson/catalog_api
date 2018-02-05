defmodule CatalogApi.Url do
  alias CatalogApi.Credentials

  def url_for(method, extra_params \\ %{}) do
    cred_params = credential_params(method)
    encoded_params = cred_params <> URI.encode_query(extra_params)
    base_url(method) <> "?" <> encoded_params
  end

  def base_url(method) do
    {username, environment} = retrieve_username_and_environment()
   "https://#{username}.#{environment}.catalogapi.com/v1/rest/#{method}"
  end

  defp retrieve_username_and_environment() do
    username = Application.get_env(:catalog_api, :username)
    if is_nil(username) do
      raise """
      no :username key set in application configuration.
      Please set the :username key in config for :catalog_api in config/config.exs
      """
    end
    environment = case Application.get_env(:catalog_api, :environment) do
      nil ->
        raise """
        no :environment key set in application configuration.
        Please set the :environment key in config for :catalog_api in config/config.exs
        """
      "dev" -> "dev"
      "prod" -> "prod"
      _ ->
        raise """
        invalid :environment key set in application configuration.
        value must be "dev" or "prod".
        """
    end
    {username, environment}
  end

  defp validate_username_and_environment(username, environment) do
  end

  def credential_params(method) do
    method
    |> Credentials.creds_for_request
    |> URI.encode_query
  end
end
