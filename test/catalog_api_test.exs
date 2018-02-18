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
      body = "{\"Fault\": {\"faultcode\": \"Client.ArgumentError\", \"faultstring\": \"A valid socket_id is required.\", \"detail\": null}}"
      catalog_response = %HTTPoison.Response{
        body: body,
        headers: @response_headers,
        request_url: "",
        status_code: 400
      }
      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
        response = CatalogApi.search_catalog(123)
        assert {:error, {:catalog_api_fault, %Fault{}}} = response
      end
    end

    test "returns an error tuple when CatalogApi responds with an internal server error" do
      catalog_response = %HTTPoison.Response{
        body: "",
        headers: @response_headers,
        request_url: "",
        status_code: 500
      }
      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
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
      body = "{\"Fault\": {\"faultcode\": \"Client.ArgumentError\", \"faultstring\": \"A valid socket_id is required.\", \"detail\": null}}"
      catalog_response = %HTTPoison.Response{
        body: body,
        headers: @response_headers,
        request_url: "",
        status_code: 400
      }
      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
        response = CatalogApi.view_item(123, 456)
        assert {:error, {:catalog_api_fault, %Fault{}}} = response
      end
    end

    test "returns an error tuple when CatalogApi responds with an internal server error" do
      catalog_response = %HTTPoison.Response{
        body: "",
        headers: @response_headers,
        request_url: "",
        status_code: 500
      }
      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
        response = CatalogApi.view_item(123, 456)
        assert {:error, {:bad_status, 500}} = response
      end
    end
  end
end
