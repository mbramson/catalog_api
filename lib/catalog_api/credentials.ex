defmodule CatalogApi.Credentials do

  @doc """
  Produces a tuple containing the uuid, datetime, and checksum necessary to
  provide credentials to make and authenticated request to CatalogApi.
  """
  @spec creds_for_request(String.t) :: {String.t, String.t, Strin.t}
  def creds_for_request(method) when is_binary(method) do
    creds_datetime = current_iso_8601_datetime()
    creds_uuid     = generate_uuid()
    creds_checksum = generate_checksum(method, creds_uuid, creds_datetime)
    {creds_datetime, creds_uuid, creds_checksum}
  end

  def current_iso_8601_datetime do
    DateTime.utc_now
    |> DateTime.to_iso8601
  end

  def generate_uuid do
    UUID.uuid4()
  end

  def generate_checksum(method_name, uuid, iso_8601_datetime) do
    message = method_name <> uuid <> iso_8601_datetime
    key = Application.get_env(:catalog_api, :secret_key)

    :crypto.hmac(:sha, key, message)
    |> Base.url_encode64
  end
end
