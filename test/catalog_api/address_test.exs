defmodule CatalogApi.AddressTest do
  use ExUnit.Case
  doctest CatalogApi.Address
  alias CatalogApi.Address

  @valid_address %Address{first_name: "John",
                          last_name: "Doe",
                          address_1: "123 Street Rd",
                          city: "Cleveland",
                          state_province: "OH",
                          postal_code: "44444",
                          country: "US"}

  describe "validate/1" do
    test "returns :ok for a valid address" do
      assert :ok = Address.validate(@valid_address)
    end

    # first_name validation

    test "returns an error tuple if first_name is blank" do
      address = Map.put(@valid_address, :first_name, "")
      error_message = "cannot be blank"
      assert {:error, {:invalid_address, [{:first_name, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if first_name is longer than 40 characters" do
      first_name = "12345678901234567890123456789012345678901"
      address = Map.put(@valid_address, :first_name, first_name)
      error_message = "cannot be longer than 40 characters"
      assert {:error, {:invalid_address, [{:first_name, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if first_name is not a string" do
      address = Map.put(@valid_address, :first_name, 123)
      error_message = "must be a string"
      assert {:error, {:invalid_address, [{:first_name, [^error_message]}]}} =
        Address.validate(address)
    end

    # last_name validation

    test "returns an error tuple if last_name is blank" do
      address = Map.put(@valid_address, :last_name, "")
      error_message = "cannot be blank"
      assert {:error, {:invalid_address, [{:last_name, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if last_name is longer than 40 characters" do
      last_name = "12345678901234567890123456789012345678901"
      address = Map.put(@valid_address, :last_name, last_name)
      error_message = "cannot be longer than 40 characters"
      assert {:error, {:invalid_address, [{:last_name, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if last_name is not a string" do
      address = Map.put(@valid_address, :last_name, 123)
      error_message = "must be a string"
      assert {:error, {:invalid_address, [{:last_name, [^error_message]}]}} =
        Address.validate(address)
    end
  end
end
