defmodule CatalogApi.Item do
  @moduledoc """
  Defines the CatalogApi.Item struct and functions which are responsible for
  parsing items from CatalogApi responses.
  """

  alias CatalogApi.Coercion
  alias CatalogApi.Item

  @derive Jason.Encoder
  defstruct brand: nil,
            catalog_item_id: nil,
            catalog_price: nil,
            categories: [],
            currency: nil,
            description: nil,
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
    description has_options image_75 image_150 image_300 model name options
    original_points original_price points rank retail_price shipping_estimate
    tags)

  @boolean_fields ~w(has_options)

  def cast(item_json) when is_map(item_json) do
    item_json
    # To avoid dynamically creating atoms
    |> filter_unknown_properties
    |> Coercion.integer_fields_to_boolean(@boolean_fields, false)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
    |> to_struct
    |> cast_categories
  end

  def extract_items_from_json(%{
        "view_item_response" => %{"view_item_result" => %{"item" => item}}
      }) do
    {:ok, cast(item)}
  end

  def extract_items_from_json(%{
        "search_catalog_response" => %{
          "search_catalog_result" => %{"items" => %{"CatalogItem" => items}}
        }
      })
      when is_list(items) do
    {:ok, Enum.map(items, &cast/1)}
  end

  def extract_items_from_json(_), do: {:error, :unparseable_catalog_api_items}

  defp filter_unknown_properties(map) do
    Enum.filter(map, fn {k, _v} -> k in @valid_fields end)
  end

  defp to_struct(map), do: struct(Item, map)

  defp cast_categories(%{categories: %{"integer" => categories}} = item)
       when is_list(categories) do
    %{item | categories: categories}
  end

  defp cast_categories(item), do: %{item | categories: []}
end
