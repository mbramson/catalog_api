defmodule CatalogApi.ItemTest do
  use ExUnit.Case
  doctest CatalogApi.Item
  alias CatalogApi.Item

  @base_item_json %{"brand" => "cat",
    "catalog_item_id" => 123,
    "catalog_price" => "50.00",
    "categories" => %{},
    "currency" => "USD",
    "has_options" => 0,
    "image_75" => "image75_url.com",
    "image_150" => "image150_url.com",
    "image_300" => "image300_url.com",
    "model" => "Cat Fur",
    "name" => "Furtronic",
    "options" => %{},
    "original_points" => 1234,
    "original_price" => "64.64",
    "points" => 1234,
    "rank" => 300,
    "retail_price" => "80.00",
    "shipping_estimate" => "10.00",
    "tags" => %{"string" => []}}

  describe "cast/1" do
    test "produces an Item struct from json" do
      assert %Item{} = Item.cast(@base_item_json)
    end

    test "coerces the has_options parameter to boolean" do
      json = Map.put(@base_item_json, "has_options", 0)
      assert %Item{has_options: false} = Item.cast(json)
      json = Map.put(@base_item_json, "has_options", "0")
      assert %Item{has_options: false} = Item.cast(json)
      json = Map.put(@base_item_json, "has_options", 1)
      assert %Item{has_options: true} = Item.cast(json)
      json = Map.put(@base_item_json, "has_options", "1")
      assert %Item{has_options: true} = Item.cast(json)
    end

    test "coerces to an error value if not coercable to boolean" do
      json = Map.put(@base_item_json, "has_options", 123)
      assert %Item{has_options: {:error, :failed_boolean_coercion}}
        = Item.cast(json)
    end

    test "does not add invalid keys" do
      json = Map.put(@base_item_json, "bad_param", 123)
      result = Item.cast(json)
      refute Map.get(result, :bad_param)
      refute Map.get(result, "bad_param")
    end
  end
end
