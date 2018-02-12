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
  end
end
