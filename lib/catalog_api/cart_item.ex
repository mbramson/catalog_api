defmodule CatalogApi.CartItem do
  @moduledoc """
  Defines the CatalogApi.CartItem struct and functions which are responsible for
  parsing items in a user's cart from CatalogApi responses.
  """

  alias CatalogApi.Coercion
  alias CatalogApi.CartItem

  defstruct cart_price: nil,
            catalog_item_id: nil,
            catalog_points: nil,
            catalog_price: nil,
            currency: nil,
            error: nil,
            image_uri: nil,
            is_available: nil,
            is_valid: nil,
            name: nil,
            points: nil,
            quantity: nil,
            retail_price: nil,
            shipping_estimate: nil

  @type t :: %CatalogApi.CartItem{}

  @valid_fields ~w(cart_price catalog_item_id catalog_points catalog_price
    currency error image_uri is_available is_valid name points quantity 
    retail_price shipping_estimate)

  @boolean_fields ~w(is_available is_valid)

  @doc """
  Converts JSON representing an item in a user's cart and returns a
  %CatalogApi.CartItem{} struct.
  """
  @spec cast(map()) :: t
  def cast(item_json) when is_map(item_json) do
    item_json
    # To avoid dynamically creating atoms
    |> filter_unknown_properties
    |> Coercion.integer_fields_to_boolean(@boolean_fields)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
    |> to_struct
  end

  @doc """
  Extracts %CatalogApi.CartItem{} struct(s) from a raw parsed json response.

  If the parsed json response is not handled, returns an error tuple of the
  format `{:error, :unparseable_catalog_api_items}`.
  """
  @spec extract_items_from_json(map()) ::
          {:ok, list(t)}
          | {:error, :unparseable_catalog_api_items}
  def extract_items_from_json(%{
        "cart_view_response" => %{"cart_view_result" => %{"items" => %{"CartItem" => items}}}
      })
      when is_list(items) do
    {:ok, Enum.map(items, fn item -> cast(item) end)}
  end

  def extract_items_from_json(%{
        "cart_view_response" => %{"cart_view_result" => %{"items" => %{}}}
      }) do
    {:ok, []}
  end

  def extract_items_from_json(_), do: {:error, :unparseable_catalog_api_items}

  defp to_struct(map), do: struct(CartItem, map)

  defp filter_unknown_properties(map) do
    Enum.filter(map, fn {k, _v} -> k in @valid_fields end)
  end
end
