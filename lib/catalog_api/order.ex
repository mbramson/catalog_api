defmodule CatalogApi.Order do
  @moduledoc """
  Defines the `CatalogApi.Order` struct and associated functions for dealing
  with orders in CatalogAPI responses.
  """
  defstruct order_id: nil

  alias __MODULE__

  @type t :: %Order{}

  def cast(order_json) when is_map(order_json) do
    %Order{
      order_id: get_in(order_json, ["order_number"])
    }
  end

  def extract_from_json(%{
        "cart_order_place_response" => %{"cart_order_place_result" => order_json}
      }) do
    {:ok, cast(order_json)}
  end
  def extract_from_json(_), do: {:error, :unparseable_catalog_api_order}
end
