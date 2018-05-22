defmodule CatalogApi.CredentialsTest do
  use ExUnit.Case
  use Quixir
  alias CatalogApi.Credentials
  import CatalogApi.FormatHelper

  describe "creds_for_request/1" do
    test "returns the proper credential tuple" do
      assert %{creds_datetime: datetime, creds_uuid: uuid, creds_checksum: checksum} =
               Credentials.creds_for_request("view_item")

      assert :ok = is_iso8601_datetime_string(datetime)
      assert :ok = is_valid_uuid(uuid)
      assert :ok = is_valid_checksum(checksum)
    end
  end

  describe "current_iso_8601_datetime/0" do
    test "returns an ISO-8601 formatted datetime" do
      datetime = Credentials.current_iso_8601_datetime()
      assert :ok = is_iso8601_datetime_string(datetime)
    end
  end

  describe "generate_uuid/0" do
    test "returns a valid uuid" do
      assert :ok = Credentials.generate_uuid() |> is_valid_uuid
    end
  end

  describe "generate_checksum" do
    test "generates the correct checksum" do
      method_name = "cart_view"
      uuid = "b93cee9d-dd04-4154-9b5a-8768971e72b8"
      datetime = "2013-01-01T01:30:00Z"

      assert Credentials.generate_checksum(method_name, uuid, datetime) ==
               "VdMhe0wbSyIYeymMm2YvuCmK0vE="
    end

    test "generates valid checksum for random input" do
      ptest method: string(), uuid: string(), datetime: string() do
        checksum = Credentials.generate_checksum(method, uuid, datetime)
        assert :ok = is_valid_checksum(checksum)
      end
    end

    test "raises an error if no secret key is configured" do
      # Ya... if there are flaky tests around secret_key, this is probably the reason :(
      # Sorry future me.
      Application.delete_env(:catalog_api, :secret_key)
      method_name = "cart_view"
      uuid = "b93cee9d-dd04-4154-9b5a-8768971e72b8"
      datetime = "2013-01-01T01:30:00Z"

      assert_raise RuntimeError, "No catalog_api secret_key supplied in configuration", fn ->
        Credentials.generate_checksum(method_name, uuid, datetime)
      end

      Application.put_env(:catalog_api, :secret_key, "1234567890")
    end
  end
end
