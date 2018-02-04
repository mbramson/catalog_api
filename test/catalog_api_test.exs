defmodule CatalogApiTest do
  use ExUnit.Case
  doctest CatalogApi

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

  describe "base_url/0" do
    test "compiles using testing application environment" do
      assert "https://test-user.dev.catalogapi.com/v1/rest/" == CatalogApi.base_url()
    end
  end
end
