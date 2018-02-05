defmodule CatalogApi.UrlTest do
  use ExUnit.Case
  doctest CatalogApi.Url

  alias CatalogApi.Url
  import CatalogApi.FormatHelper

  describe "url_for/2" do
    test "produces correct url with no extra parameters" do
      url = Url.url_for("view_cart")
    end
  end

  describe "credential_params/1" do
    test "builds properly formatted params" do
      params = Url.credential_params("view_cart")
      assert [checksum_param, datetime_param, uuid_param] = params |> String.split("&")
      assert ["creds_checksum", checksum] = checksum_param |> String.split("=")
      assert :ok = checksum |> is_valid_checksum
      assert ["creds_datetime", datetime] = datetime_param |> String.split("=")
      assert :ok = datetime |> is_iso8601_datetime_string
      assert ["creds_uuid", uuid] = uuid_param |> String.split("=")
      assert :ok = uuid |> is_valid_uuid
    end
  end

  describe "base_url/0" do
    test "compiles using testing application environment" do
      assert "https://test-user.dev.catalogapi.com/v1/rest/view_cart" == Url.base_url("view_cart")
    end
  end
end
