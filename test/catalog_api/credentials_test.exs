defmodule CatalogApi.CredentialsTest do
  use ExUnit.Case
  doctest CatalogApi.Credentials
  alias CatalogApi.Credentials

  describe "generate_checksum" do
    test 'generates the correct checksum' do
      method_name = "cart_view"
      uuid = "b93cee9d-dd04-4154-9b5a-8768971e72b8"
      datetime = "2013-01-01T01:30:00Z"

      assert Credentials.generate_checksum(method_name, uuid, datetime) == "VdMhe0wbSyIYeymMm2YvuCmK0vE="
    end
  end
end
