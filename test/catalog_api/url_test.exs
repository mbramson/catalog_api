defmodule CatalogApi.UrlTest do
  use ExUnit.Case
  doctest CatalogApi.Url

  alias CatalogApi.Url

  describe "base_url/0" do
    test "compiles using testing application environment" do
      assert "https://test-user.dev.catalogapi.com/v1/rest/" == Url.base_url()
    end
  end
end
