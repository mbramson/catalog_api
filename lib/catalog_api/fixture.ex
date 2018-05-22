defmodule CatalogApi.Fixture do
  @moduledoc """
  Provides `%HTTPoison.Response{}` fixtures of CatalogAPI responses.

  These can be used to write tests which ensure that everything is wired up
  correctly through the CatalogApi package.
  """

  alias HTTPoison.Response

  @response_headers [
    {"Access-Control-Allow-Methods", "GET"},
    {"Access-Control-Allow-Origin", "*"},
    {"Content-Type", "application/json"},
    {"Date", "Sat, 17 Feb 2018 23:03:56 GMT"},
    {"Server", "nginx/1.1.19"},
    {"Content-Length", "113"},
    {"Connection", "keep-alive"}
  ]

  @fault_json "{\"Fault\": {\"faultcode\": \"Client.ArgumentError\", \"faultstring\": \"A valid socket_id is required.\", \"detail\": null}}"

  @doc """
  Returns a `%HTTPPoison.Response{}` struct with a 400 status code and a body
  which matches the Fault json structure that CatalogApi returns.

  Returns only the body text if passed an argument of false to `as_response`.
  """
  @spec fault(boolean()) :: String.t() | Response.t()
  def fault(as_response \\ true) do
    case as_response do
      true -> @fault_json |> as_response(400)
      false -> @fault_json
    end
  end

  @internal_error_json ""

  @doc """
  Returns a `%HTTPPoison.Response{}` struct with a 500 status code.
  """
  @spec internal_error() :: Response.t()
  def internal_error, do: @internal_error_json |> as_response(500)

  @search_catalog_success_json "{\"search_catalog_response\": {\"search_catalog_result\": {\"items\": {\"CatalogItem\": [{\"original_price\": \"11.42\", \"catalog_price\": \"11.42\", \"image_300\": \"https://dck0i7x64ch95.cloudfront.net/asset/b/3/e/b3ead5dc9d8e3b4e39ff4a27e3a183ac_300_.jpg\", \"name\": \"Brown Bear, Brown Bear, What Do You See?: 50th Anniversary Edition\", \"tags\": {\"string\": []}, \"brand\": \"Henry Holt & Company\", \"categories\": {\"integer\": [156, 179]}, \"rank\": 300, \"options\": {}, \"catalog_item_id\": 1168951, \"currency\": \"USD\", \"points\": 229, \"shipping_estimate\": \"4.00\", \"image_150\": \"https://dck0i7x64ch95.cloudfront.net/asset/b/3/e/b3ead5dc9d8e3b4e39ff4a27e3a183ac_150_.jpg\", \"original_points\": 229, \"retail_price\": \"7.95\", \"has_options\": 0, \"model\": \"9780805047905\", \"image_75\": \"https://dck0i7x64ch95.cloudfront.net/asset/b/3/e/b3ead5dc9d8e3b4e39ff4a27e3a183ac_75_.jpg\"}]}, \"pager\": {\"has_next\": 0, \"sort\": \"score desc\", \"page\": 1, \"first_page\": 1, \"last_page\": 1, \"has_previous\": 0, \"per_page\": 10, \"pages\": {\"integer\": [1]}, \"result_count\": 1}, \"credentials\": {\"checksum\": \"Cyawkogo/jPEmTZMD89TqQCUmkc=\", \"method\": \"search_catalog\", \"uuid\": \"5b58c232-5d2b-4bad-be28-1aeed14c6c88\", \"datetime\": \"2018-02-17T23:55:08.262679+00:00\"}}}}"

  @doc """
  Returns a `%HTTPPoison.Response{}` struct with a 200 status code and a body
  which contains a successful response to the search_catalog method.

  Returns only the body text if passed an argument of false to `as_response`.
  """
  @spec fault(boolean()) :: String.t() | Response.t()
  @spec search_catalog_success(boolean()) :: String.t() | Response.t()
  def search_catalog_success(as_response \\ true) do
    case as_response do
      true -> @search_catalog_success_json |> as_response(200)
      false -> @search_catalog_success_json
    end
  end

  @view_item_success_json "{\"view_item_response\": {\"view_item_result\": {\"item\": {\"original_price\": \"28.97\", \"catalog_price\": \"28.97\", \"image_300\": \"https://dck0i7x64ch95.cloudfront.net/asset/1/d/4/1d49ef849ac7d399ccc5ebe0f24d3b7e_300_.jpg\", \"description\": \"<ul><li>Makes rich elegant and satisfying coffee that is delicious every time</li><li>High-quality durable borosilicate glass</li><li>Stainless steel frame with chrome accents</li><li>Heat-resistant knob</li><li>Plunger that securely fits in the chrome lid</li><li>Hard plastic handle stays cool</li><li>Angled spout provides an even pour</li><li>4-Cup coffee capacity</li><li>Dishwashersafe</li><li><b>Includes:</b><ul><li>Filter spiral plate</li><li>Fine stainless steel mesh filter with cross plate</li><li>Easy to use plunger</li></uL>\", \"tags\": {\"string\": []}, \"brand\": \"Primula\", \"categories\": {\"integer\": [2848, 6, 189]}, \"rank\": 300, \"options\": {}, \"catalog_item_id\": 4404890, \"currency\": \"USD\", \"points\": 580, \"shipping_estimate\": \"17.66\", \"image_150\": \"https://dck0i7x64ch95.cloudfront.net/asset/1/d/4/1d49ef849ac7d399ccc5ebe0f24d3b7e_150_.jpg\", \"original_points\": 580, \"retail_price\": \"19.99\", \"has_options\": 0, \"model\": \"PCP-6404\", \"image_75\": \"https://dck0i7x64ch95.cloudfront.net/asset/1/d/4/1d49ef849ac7d399ccc5ebe0f24d3b7e_75_.jpg\", \"name\": \"4-Cup Classic Coffee Press\"}, \"credentials\": {\"checksum\": \"6ae/u+Fd+UGVAbkrsro8LfoVoNE=\", \"method\": \"view_item\", \"uuid\": \"f7ef214e-425e-4c26-9e89-f2f9724b513c\", \"datetime\": \"2018-02-18T20:16:46.098363+00:00\"}}}}"

  @doc """
  Returns a `%HTTPPoison.Response{}` struct with a 200 status code and a body
  which contains a successful response to the view_item method.

  Returns only the body text if passed an argument of false to `as_response`.
  """
  @spec view_item_success(boolean()) :: String.t() | Response.t()
  def view_item_success(as_response \\ true) do
    case as_response do
      true -> @view_item_success_json |> as_response(200)
      false -> @view_item_success_json
    end
  end

  @no_item_fault_json "{\"Fault\": {\"faultcode\": \"Client.APIError\", \"faultstring\": \"Invalid catalog_item_id: 123123\",\"detail\": null}}"

  @doc """
  Returns a `%HTTPPoison.Response{}` struct with a 400 status code and a body
  which contains a response to the view_item method indicating that the
  requested item did not exit

  Returns only the body text if passed an argument of false to `as_response`.
  """
  @spec no_item_fault(boolean()) :: String.t() | Response.t()
  def no_item_fault(as_response \\ true) do
    case as_response do
      true -> @no_item_fault_json |> as_response(400)
      false -> @no_item_fault_json
    end
  end

  @cart_set_address_success_json "{\"cart_set_address_response\": {\"cart_set_address_result\": {\"credentials\": {\"checksum\": \"GgSbBf1eHGqK7G3O3Db8rAIbwYI=\", \"method\": \"cart_set_address\", \"uuid\": \"77643000-adb8-444b-8775-41459e28bbaa\", \"datetime\": \"2018-02-23T02:49:07.821677+00:00\"}, \"description\": \"Address Updated\"}}}"

  @doc """
  Returns a `%HTTPPoison.Response{}` struct with a 200 status code and a body
  which contains a successful response to the cart_set_address method.

  Returns only the body text if passed an argument of false to `as_response`.
  """
  def cart_set_address_success(as_response \\ true) do
    case as_response do
      true -> @cart_set_address_success_json |> as_response(200)
      false -> @cart_set_address_success_json
    end
  end

  @cart_add_item_success_json "{\"cart_add_item_response\": {\"cart_add_item_result\": {\"credentials\": {\"checksum\": \"0/7Bp8EXqVMN199cSIZFkb6fa04=\", \"method\": \"cart_add_item\", \"uuid\": \"0bc92613-110f-4b3b-af01-4aa9b7578ed8\", \"datetime\": \"2018-02-18T20:22:25.617678+00:00\"}, \"description\": \"Item quantity increased.\"}}}"

  @doc """
  Returns a `%HTTPPoison.Response{}` struct with a 200 status code and a body
  which contains a successful response to the cart_add_item method.

  Returns only the body text if passed an argument of false to `as_response`.
  """
  def cart_add_item_success(as_response \\ true) do
    case as_response do
      true -> @cart_add_item_success_json |> as_response(200)
      false -> @cart_add_item_success_json
    end
  end

  @cart_view_success_json "{\"cart_view_response\": {\"cart_view_result\": {\"phone_number\": \"\", \"city\": \"Cleveland\", \"first_name\": \"FirstName\", \"last_name\": \"LastName\", \"locked\": 0, \"address_2\": \"\", \"items\": {\"CartItem\": [{\"catalog_price\": \"192.21\", \"catalog_points\": 3845, \"name\": \"Keurig K15 Compact Coffee Maker\", \"currency\": \"USD\", \"quantity\": 4, \"catalog_item_id\": 4424207, \"image_uri\": \"https://dck0i7x64ch95.cloudfront.net/asset/b/c/e/bce0824dc47fa64656ca09e1baf556ac_75_.jpg\", \"points\": 3845, \"is_available\": 1, \"cart_price\": \"192.21\", \"error\": \"\", \"retail_price\": \"99.99\", \"shipping_estimate\": \"89.96\", \"is_valid\": 1}]}, \"error\": \"\", \"needs_address\": 0, \"is_valid\": 1, \"cart_version\": \"a6cc98d7-f8c1-4ac3-b81a-53eaab867381\", \"postal_code\": \"44444\", \"address_1\": \"123 Street Rd\", \"state_province\": \"OH\", \"address_3\": \"\", \"credentials\": {\"checksum\": \"bIXGn/l0rGkXH+6J66CkrjHC2M0=\", \"method\": \"cart_view\", \"uuid\": \"4ba524dd-c72d-48bb-bfe9-54a499cc4398\", \"datetime\": \"2018-02-18T20:28:55.816232+00:00\"}, \"country\": \"US\", \"email\": \"\", \"has_item_errors\": 0}}}"

  @doc """
  Returns a `%HTTPPoison.Response{}` struct with a 200 status code and a body
  which contains a successful response to the cart_view method.

  Returns only the body text if passed an argument of false to `as_response`.
  """
  def cart_view_success(as_response \\ true) do
    case as_response do
      true -> @cart_view_success_json |> as_response(200)
      false -> @cart_view_success_json
    end
  end

  @cart_view_no_address_success_json "{\"cart_view_response\": {\"cart_view_result\": {\"locked\": 0, \"items\": {\"CartItem\": [{\"catalog_price\": \"28.97\", \"catalog_points\": 580, \"name\": \"4-Cup Classic Coffee Press\", \"currency\": \"USD\", \"quantity\": 1, \"catalog_item_id\": 4404890, \"image_uri\": \"https://dck0i7x64ch95.cloudfront.net/asset/1/d/4/1d49ef849ac7d399ccc5ebe0f24d3b7e_75_.jpg\", \"points\": 580, \"is_available\": 1, \"cart_price\":\"28.97\", \"error\": \"\", \"retail_price\": \"19.99\", \"shipping_estimate\": \"17.66\", \"is_valid\": 1}]}, \"cart_version\": \"7cb67931-f846-4d41-8bb2-9e544fbe7a76\", \"needs_address\": 1, \"is_valid\": 0, \"error\": \"The cart requires an address. \", \"credentials\": {\"checksum\": \"0Kly/RiY9XSCWvb2WPON+8PT3pc=\", \"method\": \"cart_view\", \"uuid\": \"f18c87c2-cf77-4fd6-b42f-1d323ddcb229\", \"datetime\": \"2018-02-18T20:39:44.126121+00:00\"}, \"has_item_errors\": 0}}}"

  @doc """
  Returns a `%HTTPPoison.Response{}` struct with a 200 status code and a body
  which contains a response from CatalogAPI indicating that the address did not
  have a valid address.

  Returns only the body text if passed an argument of false to `as_response`.
  """
  def cart_view_no_address_success(as_response \\ true) do
    case as_response do
      true -> @cart_view_no_address_success_json |> as_response(200)
      false -> @cart_view_no_address_success_json
    end
  end

  @cart_view_empty_cart_success_json "{\"cart_view_response\": {\"cart_view_result\": {\"credentials\": {\"checksum\": \"cnYAPXNzagegGC/1TWUwQhRoZCU=\", \"method\": \"cart_view\", \"uuid\": \"55470cc3-bf7d-453d-824e-faeaa922bf5b\", \"datetime\": \"2018-03-05T05:04:58.425254+00:00\"}, \"items\": {}}}}"

  @doc """
  Returns a `%HTTPPoison.Response{}` struct with a 200 status code and a body
  which contains a response from CatalogAPI indicating that the shopping cart
  is empty.

  Returns only the body text if passed an argument of false to `as_response`.
  """
  def cart_view_empty_cart_success(as_response \\ true) do
    case as_response do
      true -> @cart_view_empty_cart_success_json |> as_response(200)
      false -> @cart_view_empty_cart_success_json
    end
  end

  @cart_order_place_success_json "{\"cart_order_place_response\": {\"cart_order_place_result\": {\"credentials\": {\"checksum\": \"rgWGTavI1UmeSUczk1PkupRZTs8=\", \"method\": \"order_place\", \"uuid\": \"b015eb40-c880-4713-b771-4cd6481416f3\", \"datetime\": \"2018-02-18T20:52:31.406691+00:00\"}, \"order_number\": \"7151-11291-78980-0001\"}}}"

  @doc """
  Returns a `%HTTPPoison.Response{}` struct with a 200 status code and a body
  which contains a successful response to the cart_order_place method.

  Returns only the body text if passed an argument of false to `as_response`.
  """
  def cart_order_place_success(as_response \\ true) do
    case as_response do
      true -> @cart_order_place_success_json |> as_response(200)
      false -> @cart_order_place_success_json
    end
  end

  @bad_cart_version_fault_json "{\"Fault\": {\"faultcode\": \"Client.APIError\", \"faultstring\": \"The given cart version does not match the cart.\", \"detail\": null}}"

  @doc """
  Returns a `%HttpPoison.Response{}` struct with a 400 status code and a body
  which contains an error response indicating that the supplied cart_version
  parameter did not match the current version of the cart.

  Returns only the body text if passed an argument of false to `as_response`.
  """
  def bad_cart_version_fault(as_response \\ true) do
    case as_response do
      true -> @bad_cart_version_fault_json |> as_response(400)
      false -> @bad_cart_version_fault_json
    end
  end

  @spec as_response(String.t(), integer()) :: Response.t()
  defp as_response(body, status) do
    %HTTPoison.Response{
      body: body,
      headers: @response_headers,
      request_url: "",
      status_code: status
    }
  end
end
