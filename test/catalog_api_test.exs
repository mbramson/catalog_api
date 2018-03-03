defmodule CatalogApiTest do
  use ExUnit.Case, async: false
  doctest CatalogApi

  import Mock

  alias CatalogApi.CartItem
  alias CatalogApi.Fault
  alias CatalogApi.Fixture
  alias CatalogApi.Item

  @response_headers [
    {"Access-Control-Allow-Methods", "GET"},
    {"Access-Control-Allow-Origin", "*"},
    {"Content-Type", "application/json"},
    {"Date", "Sat, 17 Feb 2018 23:03:56 GMT"},
    {"Server", "nginx/1.1.19"},
    {"Content-Length", "113"},
    {"Connection", "keep-alive"}
  ]

  @valid_address %{first_name: "john",
                   last_name: "doe",
                   address_1: "1 Street rd",
                   city: "Cleveland",
                   state_province: "OH",
                   postal_code: "44444",
                   country: "US"}

  @fault_response Fixture.fault(true)

  @internal_error_response Fixture.internal_error()

  describe "search_catalog/2" do
    test "returns a list of items and page info upon success" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, Fixture.search_catalog_success()} end] do
        response = CatalogApi.search_catalog(123)
        assert {:ok, %{items: items, page_info: _page_info}} = response
        Enum.map(items, &(assert %Item{} = &1))
      end
    end

    test "returns an error tuple with a fault struct when CatalogApi responds with a fault" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @fault_response} end] do
        response = CatalogApi.search_catalog(123)
        assert {:error, {:catalog_api_fault, %Fault{}}} = response
      end
    end

    test "returns an error tuple when CatalogApi responds with an internal server error" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @internal_error_response} end] do
        response = CatalogApi.search_catalog(123)
        assert {:error, {:bad_catalog_api_status, 500}} = response
      end
    end
  end

  describe "view_item/2" do
    test "returns an Item struct for a successful response" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, Fixture.view_item_success()} end] do
        response = CatalogApi.view_item(123, 456)
        assert {:ok, %{item: %Item{}}} = response
      end
    end

    test "returns a :not_found error tuple when CatalogApi indicates item does not exist" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, Fixture.no_item_fault()} end] do
        response = CatalogApi.view_item(123, 456)
        assert {:error, :item_not_found} = response
      end
    end

    test "returns an error tuple with a fault struct when CatalogApi responds with a fault" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @fault_response} end] do
        response = CatalogApi.view_item(123, 456)
        assert {:error, {:catalog_api_fault, %Fault{}}} = response
      end
    end

    test "returns an error tuple when CatalogApi responds with an internal server error" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @internal_error_response} end] do
        response = CatalogApi.view_item(123, 456)
        assert {:error, {:bad_catalog_api_status, 500}} = response
      end
    end
  end

  describe "cart_set_address/3" do
    test "returns a description if the response is successful" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, Fixture.cart_set_address_success()} end] do
        response = CatalogApi.cart_set_address(123, 1, @valid_address)
        assert {:ok, %{description: "Address Updated"}} = response
      end
    end

    test "returns invalid address error tuple if address is not valid" do
      invalid_address = Map.put(@valid_address, :first_name, "")
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @internal_error_response} end] do
        response = CatalogApi.cart_set_address(123, 1, invalid_address)
        assert {:error, {:invalid_address, [{:first_name, ["cannot be blank"]}]}} = response
      end
    end

    test "returns an error tuple with a fault struct when CatalogApi responds with a fault" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @fault_response} end] do
        response = CatalogApi.cart_set_address(123, 1, @valid_address)
        assert {:error, {:catalog_api_fault, %Fault{}}} = response
      end
    end

    test "returns an error tuple when CatalogApi responds with an internal server error" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @internal_error_response} end] do
        response = CatalogApi.cart_set_address(123, 1, @valid_address)
        assert {:error, {:bad_catalog_api_status, 500}} = response
      end
    end
  end

  describe "cart_add_item/4" do
    test "returns a description if the response is successful" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, Fixture.cart_add_item_success()} end] do
        response = CatalogApi.cart_add_item(123, 1, 456)
        assert {:ok, %{description: "Item quantity increased."}} = response
      end
    end

    # TODO: Add a test for when add_item fails because the item does not exist
    # This should have a custom return.

    test "returns an error tuple with a fault struct when CatalogApi responds with a fault" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @fault_response} end] do
        response = CatalogApi.cart_add_item(123, 1, 456)
        assert {:error, {:catalog_api_fault, %Fault{}}} = response
      end
    end

    test "returns an error tuple when CatalogApi responds with an internal server error" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @internal_error_response} end] do
        response = CatalogApi.cart_add_item(123, 1, 456)
        assert {:error, {:bad_catalog_api_status, 500}} = response
      end
    end
  end

  describe "cart_view/2" do
    test "returns items in cart and the cart status for a successful response" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, Fixture.cart_view_success()} end] do
        response = CatalogApi.cart_view(123, 1)
        assert {:ok, %{items: items, status: status}} = response

        Enum.map(items, &(assert %CartItem{} = &1))

        assert status[:error] == ""
        assert status[:has_item_errors] == false
        assert status[:is_valid] == true
        assert status[:locked] == false
        assert status[:needs_address] == false
        assert status[:cart_version] == "a6cc98d7-f8c1-4ac3-b81a-53eaab867381"
      end
    end

    test "returns items in cart if successful response but no address info" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, Fixture.cart_view_no_address_success()} end] do
        response = CatalogApi.cart_view(123, 1)
        assert {:ok, %{items: items, status: status}} = response

        Enum.map(items, &(assert %CartItem{} = &1))

        assert status[:error] == "The cart requires an address. "
        assert status[:has_item_errors] == false
        assert status[:is_valid] == false
        assert status[:locked] == false
        assert status[:needs_address] == true
        assert status[:cart_version] == "7cb67931-f846-4d41-8bb2-9e544fbe7a76"
      end
    end

    test "returns an error tuple with a fault struct when CatalogApi responds with a fault" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @fault_response} end] do
        response = CatalogApi.cart_view(123, 1)
        assert {:error, {:catalog_api_fault, %Fault{}}} = response
      end
    end

    test "returns an error tuple when CatalogApi responds with an internal server error" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @internal_error_response} end] do
        response = CatalogApi.cart_view(123, 1)
        assert {:error, {:bad_catalog_api_status, 500}} = response
      end
    end
  end

  describe "cart_order_place/3" do
    test "returns order information if order is successfully placed" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, Fixture.cart_order_place_success()} end] do
        response = CatalogApi.cart_order_place(1061, 1)
        assert {:ok, _json} = response
      end
    end

    test "returns an error tuple if the cart is not found" do
      body = "{\"Fault\": {\"faultcode\": \"Client.APIError\", \"faultstring\": \"Cart not found.\", \"detail\":null}}"
      catalog_response = %HTTPoison.Response{
        body: body,
        headers: @response_headers,
        request_url: "",
        status_code: 400
      }
      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
        response = CatalogApi.cart_order_place(1061, 1)
        assert {:error, :cart_not_found} = response
      end
    end

    test "returns an error tuple if the cart has no shipping address" do
      body = "{\"Fault\": {\"faultcode\": \"Client.APIError\", \"faultstring\": \"A shipping address must be added to the cart.\", \"detail\": null}}"
      catalog_response = %HTTPoison.Response{
        body: body,
        headers: @response_headers,
        request_url: "",
        status_code: 400
      }
      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
        response = CatalogApi.cart_order_place(1061, 1)
        assert {:error, :no_shipping_address} = response
      end

    end

    test "returns an error tuple with a fault struct when CatalogApi responds with a fault" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @fault_response} end] do
        response = CatalogApi.cart_order_place(1061, 1)
        assert {:error, {:catalog_api_fault, %Fault{}}} = response
      end
    end

    test "returns an error tuple when CatalogApi responds with an internal server error" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @internal_error_response} end] do
        response = CatalogApi.cart_order_place(1061, 1)
        assert {:error, {:bad_catalog_api_status, 500}} = response
      end
    end
  end
end
