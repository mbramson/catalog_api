defmodule CatalogApi.OrderTest do
  use ExUnit.Case, async: true

  alias CatalogApi.Order

  @base_order_json %{
    "order_number" => "9563-02338-18554-0001"
  }

  describe "cast/1" do
    test "produces an order from standard order_json" do
      order = Order.cast(@base_order_json)
      assert %Order{} = order
      assert order.order_id == @base_order_json["order_number"]
    end
  end

  describe "extract_order_from_json" do
    test "extracts from cart_order_place response json" do
      json = %{"cart_order_place_response" => %{"cart_order_place_result" => @base_order_json}}

      assert {:ok, order} = Order.extract_from_json(json)
      assert order.order_id == @base_order_json["order_number"]
    end

    test "returns error for unhandled json" do
      assert {:error, :unparseable_catalog_api_order} == Order.extract_from_json(%{})
    end
  end
end
