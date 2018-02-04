defmodule CatalogApi.Checksum do

  def generate_checksum(method_name, uuid, iso_8601_datetime) do
    message = method_name <> uuid <> iso_8601_datetime
    key = Application.get_env(:catalog_api, :secret_key)

    :crypto.hmac(:sha, key, message)
    |> Base.url_encode64
  end
end
