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

  @type t :: %CatalogApi.Category{}

  @valid_fields ~w(category_id children depth item_count name parent_category_id)

  @doc """
  Casts a map representing a Category which results from parsing JSON
  representing a category into a `%CatalogApi.Category{}` struct.

  If the category has any categories enumerated in its "children" key, then it
  casts those children recursively as well.
  """
  @spec cast(map()) :: t()
  def cast(category_json) when is_map(category_json) do
    category_json
    |> filter_unknown_properties
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
    |> to_struct
    |> cast_child_categories
  end

  @doc """
  Accepts a raw JSON response from the `CatalogApi.catalog_breakdon/2` function
  and casts all categories as `%CatalogApi.Category{}` structs.

  If the given json is not recognized or is an invalid format then it returns
  an error tuple of the format: `{:error, :unparseable_catalog_api_categories}`
  """
  @spec extract_categories_from_json(any()) ::
    {:ok, list(t())}
    {:error, :unparseable_catalog_api_categories}
  def extract_categories_from_json(
    %{"catalog_breakdown_response" =>
      %{"catalog_breakdown_result" =>
        %{"categories" =>
          %{"Category" => categories}}}}) when is_list(categories) do
    {:ok, Enum.map(categories, &cast/1)}
  end
  def extract_categories_from_json(_), do: {:error, :unparseable_catalog_api_categories}

  defp filter_unknown_properties(map) do
    Enum.filter(map, fn {k, _v} -> k in @valid_fields end)
  end

  defp to_struct(map), do: struct(Category, map)

  defp cast_child_categories(%Category{children: %{"Category" => raw_child_categories}} = category) do
    child_categories = raw_child_categories |> Enum.map(&cast/1)
    %{category | children: child_categories}
  end
  defp cast_child_categories(%Category{children: %{}} = category) do
    %{category | children: []}
  end
  defp cast_child_categories(%Category{} = category), do: category
end
