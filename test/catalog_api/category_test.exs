defmodule CatalogApi.CategoryTest do
  use ExUnit.Case, async: true

  alias CatalogApi.Category

  @base_category_json %{"category_id" => 123,
    "children" => %{"Category" => []},
    "depth" => 2,
    "item_count" => 99,
    "name" => "video games",
    "parent_category_id" => 0}

  @other_category_json %{"category_id" => 456,
    "children" => %{"Category" => []},
    "depth" => 5,
    "item_count" => 50,
    "name" => "strategy games",
    "parent_category_id" => 123}

  describe "cast/1" do
    test "produces a category struct from json" do
      assert %Category{} = Category.cast(@base_category_json)
    end

    test "contains all of the original values" do
      category = Category.cast(@base_category_json)
      assert %Category{} = category
      assert category.category_id == 123
      assert category.depth == 2
      assert category.item_count == 99
      assert category.name == "video games"
      assert category.parent_category_id == 0
    end

    test "casts children to empty list when empty" do
      category = Category.cast(@base_category_json)
      assert %Category{} = category
      assert category.children == []
    end

    test "casts children categories also" do
      one_child_category = %{"Category" => [@other_category_json]}
      json = Map.put(@base_category_json, "children", one_child_category)
      category = Category.cast(json)
      assert %Category{} = category
      assert [child_category] = category.children
      assert %Category{} = child_category
      assert child_category.category_id == 456
      assert child_category.children == []
      assert child_category.depth == 5
      assert child_category.item_count == 50
      assert child_category.name == "strategy games"
      assert child_category.parent_category_id == 123
    end

    test "correctly formats children when children is a map" do
      category_json = %{@base_category_json | "children" => %{}}
      category = Category.cast(category_json)
      assert %Category{} = category
      assert [] = category.children
    end

    test "does not add invalid keys" do
      json = Map.put(@base_category_json, "bad_param", 123)
      result = Category.cast(json)
      refute Map.get(result, :bad_param)
      refute Map.get(result, "bad_param")
    end
  end

  describe "extract_items_from_json/1" do
    test "extracts a cetegory from the catalog_breakdown response" do
      json = %{"catalog_breakdown_response" =>
        %{"catalog_breakdown_result" =>
          %{"categories" =>
            %{"Category" => [@base_category_json]}}}}
      assert {:ok, [category]} = Category.extract_categories_from_json(json)
      assert %Category{} = category
      assert category.category_id == 123
      assert category.children == []
      assert category.depth == 2
      assert category.item_count == 99
      assert category.name == "video games"
      assert category.parent_category_id == 0
    end

    test "returns an error tuple if structure is not parseable" do
      assert {:error, :unparseable_catalog_api_categories} =
        Category.extract_categories_from_json(%{})

    end

  end
end
