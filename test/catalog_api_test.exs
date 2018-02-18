defmodule CatalogApiTest do
  use ExUnit.Case, async: false
  doctest CatalogApi

  import Mock

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

    test "returns an error tuple when CatalogApi responds with a fault" do
      body = "{\"Fault\": {\"faultcode\": \"Client.ArgumentError\", \"faultstring\": \"A valid socket_id is required.\", \"detail\": null}}"
      catalog_response = %HTTPoison.Response{
        body: body,
        headers: @response_headers,
        request_url: "",
        status_code: 400
      }
      with_mock HTTPoison, [get: fn(_url) -> {:ok, catalog_response} end] do
        response = CatalogApi.search_catalog(123)
        assert {:error, {:bad_status, 400}} = response
      end
    end
  end
end
