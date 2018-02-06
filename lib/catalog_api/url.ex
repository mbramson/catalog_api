defmodule CatalogApi.Url do
  @moduledoc """
  Contains functions which help construct the url for a request to CatalogAPI.
  """
  alias CatalogApi.Credentials

  @doc """
  Produces the url for the given method and extra parameters that can be used
  to make a valid request to CatalogApi.

  ## Examples
      iex> url_for("view_cart")
      "https://test-user.dev.catalogapi.com/v1/rest/view_cart?creds_checksum=cdDvWQi0l4QvG_BFFsTafVJofp0%3D&creds_datetime=2018-02-06T02%3A19%3A30.316504Z&creds_uuid=b712435b-9095-4234-8f8f-ba6e4c53701e"

      iex> extra_params = %{socket_id: "123", catalog_item_id: "456"}
      ...> url_for("view_item", extra_params)
      "https://test-user.dev.catalogapi.com/v1/rest/view_item?catalog_item_id=456&creds_checksum=g-e39oSH7Oobh5SD-Ph9r3UALmI%3D&creds_datetime=2018-02-06T02%3A22%3A10.364838Z&creds_uuid=ec61ff5e-7662-4f50-84fc-85e453996b40&socket_id=123"
  """
  def url_for(method, extra_params \\ %{}) do
    cred_params = method |> Credentials.creds_for_request
    params = extra_params |> Map.merge(cred_params)
    encoded_params = URI.encode_query(params)
    base_url(method) <> "?" <> encoded_params
  end

  @doc """
  Produces the base url for the given method as well as the current username
  and environment set in the configuration for :catalog_api.

  ## Example
      iex> base_url("list_available_catalogs")
      "https://test-user.dev.catalogapi.com/v1/rest/list_available_catalogs"
  """
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
end
