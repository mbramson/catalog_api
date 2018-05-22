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

    test "casts categories to a list" do
      item = Item.cast(@base_item_json)
      assert %Item{} = item
      assert item.categories == []

      item_json = @base_item_json |> Map.put("categories", %{"integer" => [1, 2, 3]})
      item = Item.cast(item_json)
      assert %Item{} = item
      assert item.categories == [1, 2, 3]
    end
  end

  describe "extract_item_from_json/1" do
    test "extracts an item from the view_item response structure" do
      json = %{"view_item_response" => %{"view_item_result" => %{"item" => @base_item_json}}}
      assert {:ok, %Item{}} = Item.extract_items_from_json(json)
    end

    test "extracts items from the search_catalog response structure" do
      items = [@base_item_json, @base_item_json]
      json = %{"search_catalog_response" => %{"search_catalog_result" =>
        %{"items" => %{"CatalogItem" => items}}}}
      assert {:ok, [%Item{}, %Item{}]} = Item.extract_items_from_json(json)
    end

    test "returns an error tuple if structure is not parseable" do
      error = {:error, :unparseable_catalog_api_items}
      assert ^error = Item.extract_items_from_json(nil)
      assert ^error = Item.extract_items_from_json(%{})
      assert ^error = Item.extract_items_from_json([])
    end
  end
end
