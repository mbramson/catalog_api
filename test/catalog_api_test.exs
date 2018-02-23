defmodule CatalogApiTest do
  use ExUnit.Case, async: false
  doctest CatalogApi

  import Mock

  alias CatalogApi.Fault
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

  @fault_response %HTTPoison.Response{
      body: "{\"Fault\": {\"faultcode\": \"Client.ArgumentError\", \"faultstring\": \"A valid socket_id is required.\", \"detail\": null}}",
      headers: @response_headers,
      request_url: "",
      status_code: 400
    }

  @internal_error_response %HTTPoison.Response{
      body: "",
      headers: @response_headers,
      request_url: "",
      status_code: 500
    }

  describe "search_catalog/2" do
    test "returns a list of items and page info upon success" do
      body = "{\"search_catalog_response\": {\"search_catalog_result\": {\"items\": {\"CatalogItem\": [{\"original_price\": \"11.42\", \"catalog_price\": \"11.42\", \"image_300\": \"https://dck0i7x64ch95.cloudfront.net/asset/b/3/e/b3ead5dc9d8e3b4e39ff4a27e3a183ac_300_.jpg\", \"name\": \"Brown Bear, Brown Bear, What Do You See?: 50th Anniversary Edition\", \"tags\": {\"string\": []}, \"brand\": \"Henry Holt & Company\", \"categories\": {\"integer\": [156, 179]}, \"rank\": 300, \"options\": {}, \"catalog_item_id\": 1168951, \"currency\": \"USD\", \"points\": 229, \"shipping_estimate\": \"4.00\", \"image_150\": \"https://dck0i7x64ch95.cloudfront.net/asset/b/3/e/b3ead5dc9d8e3b4e39ff4a27e3a183ac_150_.jpg\", \"original_points\": 229, \"retail_price\": \"7.95\", \"has_options\": 0, \"model\": \"9780805047905\", \"image_75\": \"https://dck0i7x64ch95.cloudfront.net/asset/b/3/e/b3ead5dc9d8e3b4e39ff4a27e3a183ac_75_.jpg\"}]}, \"pager\": {\"has_next\": 0, \"sort\": \"score desc\", \"page\": 1, \"first_page\": 1, \"last_page\": 1, \"has_previous\": 0, \"per_page\": 10, \"pages\": {\"integer\": [1]}, \"result_count\": 1}, \"credentials\": {\"checksum\": \"Cyawkogo/jPEmTZMD89TqQCUmkc=\", \"method\": \"search_catalog\", \"uuid\": \"5b58c232-5d2b-4bad-be28-1aeed14c6c88\", \"datetime\": \"2018-02-17T23:55:08.262679+00:00\"}}}}"
      catalog_response = %HTTPoison.Response{
        body: body,
        headers: @response_headers,
        request_url: "",
        status_code: 200
      }
      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
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
        assert {:error, {:bad_status, 500}} = response
      end
    end
  end

  describe "view_item/2" do
    test "returns an Item struct for a successful response" do
      body = "{\"view_item_response\": {\"view_item_result\": {\"item\": {\"original_price\": \"28.97\", \"catalog_price\": \"28.97\", \"image_300\": \"https://dck0i7x64ch95.cloudfront.net/asset/1/d/4/1d49ef849ac7d399ccc5ebe0f24d3b7e_300_.jpg\", \"description\": \"<ul><li>Makes rich elegant and satisfying coffee that is delicious every time</li><li>High-quality durable borosilicate glass</li><li>Stainless steel frame with chrome accents</li><li>Heat-resistant knob</li><li>Plunger that securely fits in the chrome lid</li><li>Hard plastic handle stays cool</li><li>Angled spout provides an even pour</li><li>4-Cup coffee capacity</li><li>Dishwashersafe</li><li><b>Includes:</b><ul><li>Filter spiral plate</li><li>Fine stainless steel mesh filter with cross plate</li><li>Easy to use plunger</li></uL>\", \"tags\": {\"string\": []}, \"brand\": \"Primula\", \"categories\": {\"integer\": [2848, 6, 189]}, \"rank\": 300, \"options\": {}, \"catalog_item_id\": 4404890, \"currency\": \"USD\", \"points\": 580, \"shipping_estimate\": \"17.66\", \"image_150\": \"https://dck0i7x64ch95.cloudfront.net/asset/1/d/4/1d49ef849ac7d399ccc5ebe0f24d3b7e_150_.jpg\", \"original_points\": 580, \"retail_price\": \"19.99\", \"has_options\": 0, \"model\": \"PCP-6404\", \"image_75\": \"https://dck0i7x64ch95.cloudfront.net/asset/1/d/4/1d49ef849ac7d399ccc5ebe0f24d3b7e_75_.jpg\", \"name\": \"4-Cup Classic Coffee Press\"}, \"credentials\": {\"checksum\": \"6ae/u+Fd+UGVAbkrsro8LfoVoNE=\", \"method\": \"view_item\", \"uuid\": \"f7ef214e-425e-4c26-9e89-f2f9724b513c\", \"datetime\": \"2018-02-18T20:16:46.098363+00:00\"}}}}"
      catalog_response = %HTTPoison.Response{
        body: body,
        headers: @response_headers,
        request_url: "",
        status_code: 200
      }
      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
        response = CatalogApi.view_item(123, 456)
        assert {:ok, %{item: %Item{}}} = response
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
        assert {:error, {:bad_status, 500}} = response
      end
    end
  end

  describe "cart_set_address/3" do
    test "returns a description if the response is successful" do
      body = "{\"cart_set_address_response\": {\"cart_set_address_result\": {\"credentials\": {\"checksum\": \"GgSbBf1eHGqK7G3O3Db8rAIbwYI=\", \"method\": \"cart_set_address\", \"uuid\": \"77643000-adb8-444b-8775-41459e28bbaa\", \"datetime\": \"2018-02-23T02:49:07.821677+00:00\"}, \"description\": \"Address Updated\"}}}"
      catalog_response = %HTTPoison.Response{
        body: body,
        headers: @response_headers,
        request_url: "",
        status_code: 200
      }

      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
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
        assert {:error, {:bad_status, 500}} = response
      end
    end
  end

  describe "cart_add_item/4" do
    test "returns a description if the response is successful" do
      body = "{\"cart_add_item_response\": {\"cart_add_item_result\": {\"credentials\": {\"checksum\": \"0/7Bp8EXqVMN199cSIZFkb6fa04=\", \"method\": \"cart_add_item\", \"uuid\": \"0bc92613-110f-4b3b-af01-4aa9b7578ed8\", \"datetime\": \"2018-02-18T20:22:25.617678+00:00\"}, \"description\": \"Item quantity increased.\"}}}"
      catalog_response = %HTTPoison.Response{
        body: body,
        headers: @response_headers,
        request_url: "",
        status_code: 200
      }
      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
        response = CatalogApi.cart_add_item(123, 1, 456)
        assert {:ok, %{description: "Item quantity increased."}} = response
      end
    end

    test "returns an error tuple with a fault struct when CatalogApi responds with a fault" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @fault_response} end] do
        response = CatalogApi.cart_add_item(123, 1, 456)
        assert {:error, {:catalog_api_fault, %Fault{}}} = response
      end
    end

    test "returns an error tuple when CatalogApi responds with an internal server error" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @internal_error_response} end] do
        response = CatalogApi.cart_add_item(123, 1, 456)
        assert {:error, {:bad_status, 500}} = response
      end
    end
  end

  describe "cart_view/2" do
    test "returns items in cart and the cart status for a successful response" do
      body = "{\"cart_view_response\": {\"cart_view_result\": {\"phone_number\": \"\", \"city\": \"Cleveland\", \"first_name\": \"FirstName\", \"last_name\": \"LastName\", \"locked\": 0, \"address_2\": \"\", \"items\": {\"CartItem\": [{\"catalog_price\": \"192.21\", \"catalog_points\": 3845, \"name\": \"Keurig K15 Compact Coffee Maker\", \"currency\": \"USD\", \"quantity\": 4, \"catalog_item_id\": 4424207, \"image_uri\": \"https://dck0i7x64ch95.cloudfront.net/asset/b/c/e/bce0824dc47fa64656ca09e1baf556ac_75_.jpg\", \"points\": 3845, \"is_available\": 1, \"cart_price\": \"192.21\", \"error\": \"\", \"retail_price\": \"99.99\", \"shipping_estimate\": \"89.96\", \"is_valid\": 1}]}, \"error\": \"\", \"needs_address\": 0, \"is_valid\": 1, \"cart_version\": \"a6cc98d7-f8c1-4ac3-b81a-53eaab867381\", \"postal_code\": \"44444\", \"address_1\": \"123 Street Rd\", \"state_province\": \"OH\", \"address_3\": \"\", \"credentials\": {\"checksum\": \"bIXGn/l0rGkXH+6J66CkrjHC2M0=\", \"method\": \"cart_view\", \"uuid\": \"4ba524dd-c72d-48bb-bfe9-54a499cc4398\", \"datetime\": \"2018-02-18T20:28:55.816232+00:00\"}, \"country\": \"US\", \"email\": \"\", \"has_item_errors\": 0}}}"
      catalog_response = %HTTPoison.Response{
        body: body,
        headers: @response_headers,
        request_url: "",
        status_code: 200
      }
      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
        response = CatalogApi.cart_view(123, 1)
        assert {:ok, %{items: items, status: status}} = response

        Enum.map(items, &(assert %Item{} = &1))

        assert status[:error] == ""
        assert status[:has_item_errors] == false
        assert status[:is_valid] == true
        assert status[:locked] == false
        assert status[:needs_address] == false
        assert status[:cart_version] == "a6cc98d7-f8c1-4ac3-b81a-53eaab867381"
      end
    end

    test "returns items in cart if successful response but no address info" do
      body = "{\"cart_view_response\": {\"cart_view_result\": {\"locked\": 0, \"items\": {\"CartItem\": [{\"catalog_price\": \"28.97\", \"catalog_points\": 580, \"name\": \"4-Cup Classic Coffee Press\", \"currency\": \"USD\", \"quantity\": 1, \"catalog_item_id\": 4404890, \"image_uri\": \"https://dck0i7x64ch95.cloudfront.net/asset/1/d/4/1d49ef849ac7d399ccc5ebe0f24d3b7e_75_.jpg\", \"points\": 580, \"is_available\": 1, \"cart_price\":\"28.97\", \"error\": \"\", \"retail_price\": \"19.99\", \"shipping_estimate\": \"17.66\", \"is_valid\": 1}]}, \"cart_version\": \"7cb67931-f846-4d41-8bb2-9e544fbe7a76\", \"needs_address\": 1, \"is_valid\": 0, \"error\": \"The cart requires an address. \", \"credentials\": {\"checksum\": \"0Kly/RiY9XSCWvb2WPON+8PT3pc=\", \"method\": \"cart_view\", \"uuid\": \"f18c87c2-cf77-4fd6-b42f-1d323ddcb229\", \"datetime\": \"2018-02-18T20:39:44.126121+00:00\"}, \"has_item_errors\": 0}}}"
      catalog_response = %HTTPoison.Response{
        body: body,
        headers: @response_headers,
        request_url: "",
        status_code: 200
      }
      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
        response = CatalogApi.cart_view(123, 1)
        assert {:ok, %{items: items, status: status}} = response

        Enum.map(items, &(assert %Item{} = &1))

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
        assert {:error, {:bad_status, 500}} = response
      end
    end
  end

  describe "cart_order_place/3" do
    test "returns order information if order is successfully placed" do
      body = "{\"cart_order_place_response\": {\"cart_order_place_result\": {\"credentials\": {\"checksum\": \"rgWGTavI1UmeSUczk1PkupRZTs8=\", \"method\": \"order_place\", \"uuid\": \"b015eb40-c880-4713-b771-4cd6481416f3\", \"datetime\": \"2018-02-18T20:52:31.406691+00:00\"}, \"order_number\": \"7151-11291-78980-0001\"}}}"
      catalog_response = %HTTPoison.Response{
        body: body,
        headers: @response_headers,
        request_url: "",
        status_code: 200
      }
      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
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
        assert {:error, {:bad_status, 500}} = response
      end
    end
  end
end
