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
      first_name = "<  ten   ><  ten   ><  ten   ><  ten   >1"
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
      last_name = "<  ten   ><  ten   ><  ten   ><  ten   >1"
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

    # address_1 validation

    test "returns an error tuple if address_1 is blank" do
      address = Map.put(@valid_address, :address_1, "")
      error_message = "cannot be blank"
      assert {:error, {:invalid_address, [{:address_1, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if address_1 is longer than 75 characters" do
      address_1 = "<  ten   ><  ten   ><  ten   ><  ten   ><  ten   ><  ten   ><  ten   >123456"
      address = Map.put(@valid_address, :address_1, address_1)
      error_message = "cannot be longer than 75 characters"
      assert {:error, {:invalid_address, [{:address_1, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if address_1 is not a string" do
      address = Map.put(@valid_address, :address_1, 123)
      error_message = "must be a string"
      assert {:error, {:invalid_address, [{:address_1, [^error_message]}]}} =
        Address.validate(address)
    end

    # address_2 validation

    test "returns :ok if address_2 is blank" do
      address = Map.put(@valid_address, :address_2, "")
      assert :ok = Address.validate(address)
    end

    test "returns an error tuple if address_2 is longer than 60 characters" do
      address_2 = "<  ten   ><  ten   ><  ten   ><  ten   ><  ten   ><  ten   >1"
      address = Map.put(@valid_address, :address_2, address_2)
      error_message = "cannot be longer than 60 characters"
      assert {:error, {:invalid_address, [{:address_2, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if address_2 is not a string" do
      address = Map.put(@valid_address, :address_2, 123)
      error_message = "must be a string"
      assert {:error, {:invalid_address, [{:address_2, [^error_message]}]}} =
        Address.validate(address)
    end

    # address_3 validation

    test "returns :ok if address_3 is blank" do
      address = Map.put(@valid_address, :address_3, "")
      assert :ok = Address.validate(address)
    end

    test "returns an error tuple if address_3 is longer than 60 characters" do
      address_3 = "<  ten   ><  ten   ><  ten   ><  ten   ><  ten   ><  ten   >1"
      address = Map.put(@valid_address, :address_3, address_3)
      error_message = "cannot be longer than 60 characters"
      assert {:error, {:invalid_address, [{:address_3, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if address_3 is not a string" do
      address = Map.put(@valid_address, :address_3, 123)
      error_message = "must be a string"
      assert {:error, {:invalid_address, [{:address_3, [^error_message]}]}} =
        Address.validate(address)
    end

    # city validation

    test "returns an error tuple if city is blank" do
      address = Map.put(@valid_address, :city, "")
      error_message = "cannot be blank"
      assert {:error, {:invalid_address, [{:city, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if city is longer than 40 characters" do
      city = "<  ten   ><  ten   ><  ten   ><  ten   >1"
      address = Map.put(@valid_address, :city, city)
      error_message = "cannot be longer than 40 characters"
      assert {:error, {:invalid_address, [{:city, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if city is not a string" do
      address = Map.put(@valid_address, :city, 123)
      error_message = "must be a string"
      assert {:error, {:invalid_address, [{:city, [^error_message]}]}} =
        Address.validate(address)
    end

    # state_province validation

    test "returns an error tuple if state_province is blank" do
      address = Map.put(@valid_address, :state_province, "")
      error_message = "cannot be blank"
      assert {:error, {:invalid_address, [{:state_province, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if state_province is longer than 50 characters" do
      state_province = "<  ten   ><  ten   ><  ten   ><  ten   ><  ten   >1"
      address = Map.put(@valid_address, :state_province, state_province)
      error_message = "cannot be longer than 50 characters"
      assert {:error, {:invalid_address, [{:state_province, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if state_province is not a string" do
      address = Map.put(@valid_address, :state_province, 123)
      error_message = "must be a string"
      assert {:error, {:invalid_address, [{:state_province, [^error_message]}]}} =
        Address.validate(address)
    end

    # postal_code validation

    test "returns an error tuple if postal_code is blank" do
      address = Map.put(@valid_address, :postal_code, "")
      error_message = "cannot be blank"
      assert {:error, {:invalid_address, [{:postal_code, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if postal_code is longer than 15 characters" do
      postal_code = "<  ten   >123456"
      address = Map.put(@valid_address, :postal_code, postal_code)
      error_message = "cannot be longer than 15 characters"
      assert {:error, {:invalid_address, [{:postal_code, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if postal_code is not a string" do
      address = Map.put(@valid_address, :postal_code, 123)
      error_message = "must be a string"
      assert {:error, {:invalid_address, [{:postal_code, [^error_message]}]}} =
        Address.validate(address)
    end

    # country validation

    test "returns an error tuple if country is blank" do
      address = Map.put(@valid_address, :country, "")
      error_message = "cannot be blank"
      assert {:error, {:invalid_address, [{:country, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if country is not an ISO-3166-1 Alpha 2 Country Code" do
      address = Map.put(@valid_address, :country, "AP")
      error_message = "country code must be valid ISO 3166-1 alpha 2 country code"
      assert {:error, {:invalid_address, [{:country, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if country is not a string" do
      address = Map.put(@valid_address, :country, 123)
      error_message = "must be a string"
      assert {:error, {:invalid_address, [{:country, [^error_message]}]}} =
        Address.validate(address)
    end

    # email validation

    test "returns :ok if email is blank" do
      address = Map.put(@valid_address, :email, "")
      assert :ok = Address.validate(address)
    end

    test "returns an error tuple if email is longer than 254 characters" do
      email = String.pad_trailing("test@example.com", 255, "<  ten   >")
      address = Map.put(@valid_address, :email, email)
      error_message = "cannot be longer than 254 characters"
      assert {:error, {:invalid_address, [{:email, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if email is invalid" do
      email = "no_at_sign"
      address = Map.put(@valid_address, :email, email)
      error_message = "must be a valid email"
      assert {:error, {:invalid_address, [{:email, [^error_message]}]}} =
        Address.validate(address)
    end

    test "returns an error tuple if email is not a string" do
      address = Map.put(@valid_address, :email, 123)
      error_message = "must be a string"
      assert {:error, {:invalid_address, [{:email, [^error_message]}]}} =
        Address.validate(address)
    end
  end
end
