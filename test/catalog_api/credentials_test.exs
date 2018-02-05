defmodule CatalogApi.CredentialsTest do
  use ExUnit.Case
  doctest CatalogApi.Credentials
  alias CatalogApi.Credentials

  describe "current_iso_8601_datetime/0" do
    test "returns an ISO-8601 formatted datetime" do
      datetime = CatalogApi.current_iso_8601_datetime
      assert is_binary(datetime)
      assert <<_year::bytes-size(4)>>   <> "-" <>
             <<_month::bytes-size(2)>>  <> "-" <>
             <<_day::bytes-size(2)>>    <> "T" <>
             <<_hour::bytes-size(2)>>   <> ":" <>
             <<_minute::bytes-size(2)>> <> ":" <>
             <<_second::bytes-size(2)>> <> "." <>
             <<_rest::bytes-size(6)>>   <> "Z" = datetime
    end
  end

  describe "generate_checksum" do
    test 'generates the correct checksum' do
      method_name = "cart_view"
      uuid = "b93cee9d-dd04-4154-9b5a-8768971e72b8"
      datetime = "2013-01-01T01:30:00Z"

      assert Credentials.generate_checksum(method_name, uuid, datetime) == "VdMhe0wbSyIYeymMm2YvuCmK0vE="
    end
  end
end
