defmodule CatalogApi do

  def generate_checksum(method_name, uuid \\ :no_uuid, iso_8601_datetime \\ :no_datetime) do
    datetime = case iso_8601_datetime do
      :no_datetime      -> current_iso_8601_datetime()
      supplied_datetime -> supplied_datetime
    end

    uuid = case uuid do
      :no_uuid      -> generate_uuid()
      supplied_uuid -> supplied_uuid
    end

    message = method_name <> uuid <> datetime
    key = Application.get_env(:catalog_api, :secret_key)

    :crypto.hmac(:sha, key, message)
    |> Base.url_encode64
  end

  def current_iso_8601_datetime do
    "2013-01-01T01:30:00Z"
  end

  def generate_uuid do
    "b93cee9d-dd04-4154-9b5a-8768971e72b8"
  end
end
