defmodule CatalogApi.Item do
  @moduledoc """
  Defines the CatalogApi.Item struct and functions which are responsible for
  parsing items from CatalogApi responses.
  """

  alias CatalogApi.Coercion
  alias CatalogApi.Item

  defstruct brand: nil,
            catalog_item_id: nil,
            catalog_price: nil,
            categories: %{}, # TODO Can default be more specific?
            currency: nil,
            has_options: false,
            image_75: nil,
            image_150: nil,
            image_300: nil,
            model: nil,
            name: nil,
            options: %{},
            original_points: nil,
            original_price: nil,
            points: nil,
            rank: nil,
            retail_price: nil,
            shipping_estimate: nil,
            tags: %{}

  @type t :: %CatalogApi.Item{}

  @valid_fields ~w(brand catalog_item_id catalog_price categories currency
    has_options image_75 image_150 image_300 model name options original_points
    original_price points rank retail_price shipping_estimate tags)

  @boolean_fields ~w(has_options)

  def cast(item_json) when is_map(item_json) do
    item_json
    |> filter_unknown_properties # To avoid dynamically creating atoms
    |> Coercion.integer_fields_to_boolean(@boolean_fields)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
    |> to_struct
  end

  def extract_items_from_json(
    %{"view_item_response" =>
      %{"view_item_result" =>
        %{"item" => item}}}) do
    {:ok, cast(item)}
  end
  def extract_items_from_json(
    %{"search_catalog_response" =>
      %{"search_catalog_result" =>
        %{"items" =>
          %{"CatalogItem" => items}}}}) when is_list(items) do
    {:ok, Enum.map(items, fn item -> cast(item) end)}
  end

  def extract_items_from_json(
    %{"cart_view_response" =>
      %{"cart_view_result" =>
        %{"items" =>
          %{"CartItem" => items}}}}) when is_list(items) do
    {:ok, Enum.map(items, fn item -> cast(item) end)}
  end
  def extract_items_from_json(_), do: {:error, :unparseable_catalog_api_items}

  defp to_struct(map), do: struct(Item, map)

  defp filter_unknown_properties(map) do
    Enum.filter(map, fn {k, _v} -> k in @valid_fields end)
  end
end
