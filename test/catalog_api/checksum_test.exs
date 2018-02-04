defmodule CatalogApi.ChecksumTest do
  use ExUnit.Case
  doctest CatalogApi.Checksum
  alias CatalogApi.Checksum

  describe "generate_checksum" do
    method_name = "cart_view"
    uuid = "b93cee9d-dd04-4154-9b5a-8768971e72b8"
    datetime = "2013-01-01T01:30:00Z"

    assert Checksum.generate_checksum(method_name, uuid, datetime) == "VdMhe0wbSyIYeymMm2YvuCmK0vE="
  end
end
