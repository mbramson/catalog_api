defmodule CatalogApi.Credentials do

  @doc """
  Produces a tuple containing the uuid, datetime, and checksum necessary to
  provide credentials to make and authenticated request to CatalogApi.

  Note that the output for this function will depend on the secret key set in
  the configuration for :catalog_api. The output will also depend on the
  current time and the randomly generated uuid.

  ## Examples
      iex> Credentials.creds_for_request("view_cart")
      {"2013-01-01T01:30:00Z", "b93cee9d-dd04-4154-9b5a-8768971e72b8", "VdMhe0wbSyIYeymMm2YvuCmK0vE="}
  """
  @spec creds_for_request(String.t) ::
    %{creds_datetime: String.t, creds_uuid: String.t, creds_checksum: String.t}
  def creds_for_request(method) when is_binary(method) do
    datetime = current_iso_8601_datetime()
    uuid     = generate_uuid()
    checksum = generate_checksum(method, uuid, datetime)
    %{creds_datetime: datetime, creds_uuid: uuid, creds_checksum: checksum}
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
