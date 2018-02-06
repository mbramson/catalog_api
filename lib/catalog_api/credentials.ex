defmodule CatalogApi.Credentials do
  @moduledoc """
  Contains functions which deal with constructing the various pieces of
  credential data necessary for making an authenticated call to the CatalogApi
  endpoints.

  These pieces of data are:
  - creds_datetime: The current ISO-8601 datetime.
  - creds_uuid: A randomly generated UUID.
  - creds_checksum: An HMAC-SHA1 generated hash of the supplied currently used
    endpoint method, the creds_uuid, the creds_datetime, and the secret key
    from the application configuration's :secret_key key's value.
  """

  @doc """
  Produces a tuple containing the uuid, datetime, and checksum necessary to
  provide credentials to make and authenticated request to CatalogApi.

  Note that the output for this function will depend on the secret key set in
  the configuration for :catalog_api. The output will also depend on the
  current time and the randomly generated uuid.

  ## Example
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

  @doc """
  Produces the current ISO-8601 formatted datetime.

  ## Example
      iex> Credentials.current_iso_8601_datetime()
      "2018-02-05T02:15:00.626526Z"
  """
  def current_iso_8601_datetime do
    DateTime.utc_now
    |> DateTime.to_iso8601
  end

  @doc """
  Produces a randomly generated uuid using the UUID4 format.

  ## Example
      iex> Credentials.generate_uuid()
      "5007ef3d-a612-42b8-b629-599764415ac8"
  """
  def generate_uuid do
    UUID.uuid4()
  end

  @doc """
  Produces an HMAC-SHA1 generated hash of the method name, a uuid, an ISO 8601
  formatted datetime, and the :secret_key value from the application's
  :catalog_api configuration.

  ## Example
      iex> checksum = "b93cee9d-dd04-4154-9b5a-8768971e72b8"
      ...> datetime = "2013-01-01T01:30:00Z"
      ...> Credentials.generate_checksum("cart_view", checksum, datetime)
      "VdMhe0wbSyIYeymMm2YvuCmK0vE="
  """
  def generate_checksum(method_name, uuid, iso_8601_datetime) do
    message = method_name <> uuid <> iso_8601_datetime
    key = Application.get_env(:catalog_api, :secret_key)

    :crypto.hmac(:sha, key, message)
    |> Base.encode64
  end
end
