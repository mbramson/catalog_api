defmodule CatalogApi.CartItemTest do
  use ExUnit.Case
  doctest CatalogApi.CartItem
  alias CatalogApi.CartItem

  @base_item_json %{
    "cart_price" => "318.24",
    "catalog_item_id" => 4_439_324,
    "catalog_points" => 6365,
    "catalog_price" => "318.24",
    "currency" => "USD",
    "error" => "",
    "image_uri" => "image_url.com",
    "is_available" => 1,
    "is_valid" => 1,
    "name" => "128GB iPod touch (Space Gray) (6th Generation)",
    "points" => 6365,
    "quantity" => 1,
    "retail_price" => "279.99",
    "shipping_estimate" => "0.00"
  }

  describe "cast/1" do
    test "produces an Item struct from json" do
      assert %CartItem{} = CartItem.cast(@base_item_json)
    end

    test "coerces the has_options parameter to boolean" do
      json = Map.put(@base_item_json, "is_available", 0)
      assert %CartItem{is_available: false} = CartItem.cast(json)
      json = Map.put(@base_item_json, "is_available", 1)
      assert %CartItem{is_available: true} = CartItem.cast(json)

      json = Map.put(@base_item_json, "is_valid", 0)
      assert %CartItem{is_valid: false} = CartItem.cast(json)
      json = Map.put(@base_item_json, "is_valid", 1)
      assert %CartItem{is_valid: true} = CartItem.cast(json)
    end
  end

  describe "extract_item_from_json/1" do
    test "extracts an item from the cart_view response structure" do
      json = %{
        "cart_view_response" => %{
          "cart_view_result" => %{"items" => %{"CartItem" => [@base_item_json, @base_item_json]}}
        }
      }

      assert {:ok, [%CartItem{}, %CartItem{}]} = CartItem.extract_items_from_json(json)
    end

    test "returns an error tuple if structure is not parseable" do
      error = {:error, :unparseable_catalog_api_items}
      assert ^error = CartItem.extract_items_from_json(nil)
      assert ^error = CartItem.extract_items_from_json(%{})
      assert ^error = CartItem.extract_items_from_json([])
    end
  end
end
