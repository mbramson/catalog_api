defmodule CatalogApi.UrlTest do
  use ExUnit.Case
  doctest CatalogApi.Url

  alias CatalogApi.Url

  describe "credential_params/1" do
    test "builds properly formatted params" do
      params = Url.credential_params("view_cart")
      assert [datetime, uuid, checksum] = params |> String.split("&")
    end
  end

  describe "base_url/0" do
    test "compiles using testing application environment" do
      assert "https://test-user.dev.catalogapi.com/v1/rest/" == Url.base_url()
    end
  end
end
