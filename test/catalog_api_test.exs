defmodule CatalogApiTest do
  use ExUnit.Case
  doctest CatalogApi

  describe "current_iso_8601_datetime" do
    test "returns an ISO-8601 formatted datetime" do
      datetime = CatalogApi.current_iso_8601_datetime
      IO.inspect "doing something"
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
end
