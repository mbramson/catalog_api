defmodule CatalogApi.Category do
  @moduledoc """
  Defines the CatalogApi.Category struct and functions which are responsible
  for parsing categories from CatalogApi responses.
  """

  alias CatalogApi.Category

  defstruct category_id: nil,
            children: [],
            depth: 1,
            item_count: 0,
            name: nil,
            parent_category_id: 0

  @valid_fields ~w(category_id children depth item_count name parent_category_id)

  def cast(category_json) when is_map(category_json) do
    category_json
    |> filter_unknown_properties
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
    |> to_struct
    |> cast_child_categories
  end

  defp filter_unknown_properties(map) do
    Enum.filter(map, fn {k, _v} -> k in @valid_fields end)
  end

  defp to_struct(map), do: struct(Category, map)

  defp cast_child_categories(%Category{children: %{"Category" => raw_child_categories}} = category) do
    child_categories = raw_child_categories |> Enum.map(&cast/1)
    %{category | children: child_categories}
  end
  defp cast_child_categories(%Category{} = category), do: category
end
