defmodule CatalogApi.ErrorTest do
  use ExUnit.Case
  doctest CatalogApi.Error
  alias CatalogApi.Error
  alias CatalogApi.Fault

  describe "validate_response_status" do
    test "returns :ok for a 200 status" do
      catalog_response = %HTTPoison.Response{
        body: "",
        headers: [],
        request_url: "",
        status_code: 200
      }
      assert :ok = Error.validate_response_status(catalog_response)
    end

    test "returns :ok for a 201 status" do
      catalog_response = %HTTPoison.Response{
        body: "",
        headers: [],
        request_url: "",
        status_code: 201
      }
      assert :ok = Error.validate_response_status(catalog_response)
    end

    test "returns an error tuple with a Fault struct for a 400 status" do
      fault_body = "{\"Fault\": {\"faultcode\": \"Client.ArgumentError\", \"faultstring\": \"A valid socket_id is required.\", \"detail\": null}}"
      catalog_response = %HTTPoison.Response{
        body: fault_body,
        headers: [],
        request_url: "",
        status_code: 400
      }
      assert {:error, {:catalog_api_fault, %Fault{}}} =
        Error.validate_response_status(catalog_response)
    end

    test "returns an error tuple if the fault cannot be parsed" do
      fault_body = "{}"
      catalog_response = %HTTPoison.Response{
        body: fault_body,
        headers: [],
        request_url: "",
        status_code: 400
      }
      assert {:error, {:catalog_api_fault, {:error, :unparseable_catalog_api_fault}}} =
        Error.validate_response_status(catalog_response)
    end

    test "returns a bad status error tuple when the status is not handled" do
      catalog_response = %HTTPoison.Response{
        body: "",
        headers: [],
        request_url: "",
        status_code: 500
      }
      assert {:error, {:bad_status, 500}} =
        Error.validate_response_status(catalog_response)
    end

  end
end
