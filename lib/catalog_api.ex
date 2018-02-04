defmodule CatalogApi do

  def current_iso_8601_datetime do
    DateTime.utc_now
    |> DateTime.to_iso8601
  end

  def generate_uuid do
    UUID.uuid4()
  end

  def base_url do
    username = Application.get_env(:catalog_api, :username)
    environment = Application.get_env(:catalog_api, :environment)
    "https://#{username}.#{environment}.catalogapi.com/v1/rest/"
  end
end
