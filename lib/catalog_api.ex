defmodule CatalogApi do

  alias CatalogApi.Checksum

  @doc """
  Produces a tuple containing the uuid, datetime, and checksum necessary to
  provide credentials to make and authenticated request to CatalogApi.
  """
  @spec creds_for_request(String.t) :: {String.t, String.t, Strin.t}
  def creds_for_request(method) do
    creds_datetime = current_iso_8601_datetime()
    creds_uuid     = generate_uuid()
    creds_checksum = Checksum.generate_checksum(method, creds_uuid, creds_datetime)
    {creds_datetime, creds_uuid, creds_checksum}
  end

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
