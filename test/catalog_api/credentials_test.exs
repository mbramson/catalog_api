defmodule CatalogApi.CredentialsTest do
  use ExUnit.Case
  use Quixir
  doctest CatalogApi.Credentials, except: [creds_for_request: 1]
  alias CatalogApi.Credentials

  def assert_is_iso8601_datetime_string(datetime) do
    assert is_binary(datetime)
    assert <<_year::bytes-size(4)>>   <> "-" <>
           <<_month::bytes-size(2)>>  <> "-" <>
           <<_day::bytes-size(2)>>    <> "T" <>
           <<_hour::bytes-size(2)>>   <> ":" <>
           <<_minute::bytes-size(2)>> <> ":" <>
           <<_second::bytes-size(2)>> <> "." <>
           <<_rest::bytes-size(6)>>   <> "Z" = datetime
  end

  def assert_is_valid_uuid(uuid) do
    assert {:ok, _} = UUID.info(uuid)
  end

  def assert_is_valid_checksum(checksum) do
    assert <<_chars::bytes-size(27)>> <> "=" = checksum
  end

  describe "creds_for_request/1" do
    test "returns the proper credential tuple" do
      assert {datetime, uuid, checksum} = Credentials.creds_for_request("view_item")
      assert_is_iso8601_datetime_string(datetime)
      assert_is_valid_uuid(uuid)
      assert_is_valid_checksum(checksum)
    end
  end

  describe "current_iso_8601_datetime/0" do
    test "returns an ISO-8601 formatted datetime" do
      datetime = Credentials.current_iso_8601_datetime
      assert_is_iso8601_datetime_string(datetime)
    end
  end

  describe "generate_uuid/0" do
    test "returns a valid uuid" do
      Credentials.generate_uuid |> assert_is_valid_uuid
    end
  end

  describe "generate_checksum" do
    test 'generates the correct checksum' do
      method_name = "cart_view"
      uuid = "b93cee9d-dd04-4154-9b5a-8768971e72b8"
      datetime = "2013-01-01T01:30:00Z"

      assert Credentials.generate_checksum(method_name, uuid, datetime) == "VdMhe0wbSyIYeymMm2YvuCmK0vE="
    end

    test "generates valid checksum for random input" do
      ptest [method: string(), uuid: string(), datetime: string()] do
        checksum = Credentials.generate_checksum(method, uuid, datetime)
        assert_is_valid_checksum(checksum)
      end
    end
  end
end
