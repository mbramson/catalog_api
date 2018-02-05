defmodule CatalogApi.UrlTest do
  use ExUnit.Case
  doctest CatalogApi.Url

  alias CatalogApi.Url
  import CatalogApi.FormatHelper

  describe "url_for/2" do
    test "produces correct url with no extra parameters" do
      url = Url.url_for("view_cart")
      [base_url, params] = url |> String.split("?")
      assert base_url == "https://test-user.dev.catalogapi.com/v1/rest/view_cart"
      decoded_params = URI.decode_query(params)
      assert :ok = decoded_params["creds_checksum"] |> is_valid_checksum
      assert :ok = decoded_params["creds_datetime"] |> is_iso8601_datetime_string
      assert :ok = decoded_params["creds_uuid"] |> is_valid_uuid
    end

    test "produces correct url with extra parameters" do
      extra_params = %{socket_id: "123", catalog_item_id: "456"}
      url = Url.url_for("view_item", extra_params)
      [base_url, params] = url |> String.split("?")
      assert base_url == "https://test-user.dev.catalogapi.com/v1/rest/view_item"
      decoded_params = URI.decode_query(params)
      assert :ok = decoded_params["creds_checksum"] |> is_valid_checksum
      assert :ok = decoded_params["creds_datetime"] |> is_iso8601_datetime_string
      assert :ok = decoded_params["creds_uuid"] |> is_valid_uuid
      assert "123" == decoded_params["socket_id"]
      assert "456" == decoded_params["catalog_item_id"]
    end
  end

  describe "base_url/0" do
    test "compiles using testing application environment" do
      assert "https://test-user.dev.catalogapi.com/v1/rest/view_cart" == Url.base_url("view_cart")
    end
  end
end
