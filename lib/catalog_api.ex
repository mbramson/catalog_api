defmodule CatalogApi do

  alias CatalogApi.Url

  # TODO add param validation

  def list_available_catalogs() do
    url = Url.url_for("list_available_catalogs")
    HTTPoison.get(url)
  end

  @valid_catalog_breakdown_keys ~w(socket_id is_flat tag)
  def catalog_breakdown(socket_id, opts \\ %{}) do
    required_params = %{socket_id: socket_id}
    params = merge_required_filter_invalid(opts, required_params,
      @valid_catalog_breakdown_keys)

    #TODO convert is_flat boolean to "1" or "0"

    url = Url.url_for("catalog_breakdown", params)
    HTTPoison.get(url)
  end

  @valid_search_catalog_keys ~w(socket_id name search category_id min_points
    max_points min_price max_price max_rank tag page per_page sort
    catalog_item_ids)
  def search_catalog(socket_id, opts \\ %{}) do
    required_params = %{socket_id: socket_id}
    params = merge_required_filter_invalid(opts, required_params,
      @valid_search_catalog_keys)

    #TODO validate each search parameter when used

    url = Url.url_for("search_catalog", params)
    HTTPoison.get(url)
  end

  def view_item(socket_id, catalog_item_id) do
    params = %{socket_id: socket_id, catalog_item_id: catalog_item_id}
    url = Url.url_for("view_item", params)
    HTTPoison.get(url)
  end

  # TODO build address struct
  # TODO validate address params
  def cart_set_address(socket_id, external_user_id, address_params) do
    params = address_params
      |> Map.merge(%{socket_id: socket_id, external_user_id: external_user_id})
    url = Url.url_for("cart_set_address", params)
    HTTPoison.get(url)
  end

  def cart_set_item_quantity(socket_id, external_user_id, catalog_item_id, option_id, quantity) do
    # TODO add option_id to optional params
    params = %{socket_id: socket_id,
               external_user_id: external_user_id,
               catalog_item_id: catalog_item_id,
               option_id: option_id,
               quantity: quantity}
    url = Url.url_for("cart_set_item_quantity", params)
    HTTPoison.get(url)
  end

  def cart_add_item(socket_id, external_user_id, catalog_item_id, option_id, quantity) do
    # TODO default to quantity of 1
    # TODO add option_id to optional params
    params = %{socket_id: socket_id,
               external_user_id: external_user_id,
               catalog_item_id: catalog_item_id,
               option_id: option_id,
               quantity: quantity}
    url = Url.url_for("cart_add_item", params)
    HTTPoison.get(url)
  end

  def cart_remove_item(socket_id, external_user_id, catalog_item_id, option_id, quantity) do
    # TODO make quantity optional, as it default to current quantity
    # TODO add option_id to optional params
    params = %{
      socket_id: socket_id,
      external_user_id: external_user_id,
      catalog_item_id: catalog_item_id,
      option_id: option_id,
      quantity: quantity}
    url = Url.url_for("cart_remove_item", params)
    HTTPoison.get(url)
  end

  def cart_empty(socket_id, external_user_id) do
    params = %{socket_id: socket_id, external_user_id: external_user_id}
    url = Url.url_for("cart_empty", params)
    HTTPoison.get(url)
  end

  def cart_view(socket_id, external_user_id) do
    params = %{socket_id: socket_id, external_user_id: external_user_id}
    url = Url.url_for("cart_view", params)
    HTTPoison.get(url)
  end

  @doc """
  Validates the address and items in the cart. This is intended to be called
  just before placing an order to make sure that the order would not be
  rejected.

  If the locked argument is supplied as true, then the cart will be locked. A
  locked cart cannot be modified and the address cannot be changed. This should
  be used before processing a credit card transaction so that users cannot
  change relevant information after the transaction has been finalized.
  """
  def cart_validate(socket_id, external_user_id, locked \\ false) do
    locked = case locked do
      true  -> "1"
      false -> "0"
    end

    params = %{socket_id: socket_id, external_user_id: external_user_id, locked: locked}
    url = Url.url_for("cart_validate", params)
    HTTPoison.get(url)
  end

  @doc """
  Unlocks a cart that has been unlocked via the cart_validate method.
  """
  def cart_unlock(socket_id, external_user_id) do
    params = %{socket_id: socket_id, external_user_id: external_user_id}
    url = Url.url_for("cart_unlock", params)
    HTTPoison.get(url)
  end

  @doc """
  Places an order using the address and items in the cart. Deletes the cart if
  this request is successful. Returns an error if the order could not be
  placed.

  If the cart_version argument is supplied, this method will only succeed if
  the passed version matches the version of the current cart. This can be used
  to ensure that the state of the users cart in your application has not become
  stale before the order is placed.
  """
  def cart_order_place(socket_id, external_user_id, cart_version \\ nil) do
    cart_param = case cart_version do
      nil          -> %{}
      cart_version -> %{cart_version: cart_version}
    end

    params = cart_param
      |> Map.merge(%{socket_id: socket_id, external_user_id: external_user_id})

    url = Url.url_for("cart_order_place", params)
    HTTPoison.get(url)
  end

  def order_place() do
    #TODO this allows for an order placement all at once. Might not be needed.
  end

  @doc """
  Provides tracking information for a specific order number. Provides
  information on the current status, as well as metadata around fulfillment.

  If the item is a gift card, then this method provides additional information
  around gift card redemption as well as other metadata.
  """
  def order_track(order_number) do
    params = %{order_number: order_number}
    url = Url.url_for("order_track", params)
    HTTPoison.get(url)
  end

  @doc """
  Lists the orders placed by the user associated with the external_user_id.

  Options that can be supplied:
  - per_page: Maximum number of results to be displayed per page. Defaults to
    10. Maximum of 50.
  - page: Page of results to return.
  """
  def order_list(external_user_id, opts \\ []) do
    defaults = [per_page: 10, page: 1]
    %{per_page: per_page, page: page} =
      Keyword.merge(defaults, opts) |> Enum.into(%{})

    #TODO: validate that per_page is at most 50.

    params = %{
      external_user_id: external_user_id,
      per_page: per_page,
      page: page}

    url = Url.url_for("order_list", params)
    HTTPoison.get(url)
  end

  defp merge_required_filter_invalid(opts, required, valid_keys) do
    params = opts
    |> Enum.into(%{})
    |> Map.merge(required)
    |> convert_keys_to_string
    |> filter_invalid_keys(valid_keys)
  end

  defp convert_keys_to_string(map) do
    map
    |> Enum.map(fn {k, v} -> {convert_key_to_string(k), v} end)
    |> Enum.into(%{})
  end

  defp convert_key_to_string(key) when is_binary(key), do: key
  defp convert_key_to_string(key) when is_atom(key), do: Atom.to_string(key)

  defp filter_invalid_keys(map, valid_keys) do
    map
    |> Enum.filter(fn {k, _v} -> k in valid_keys end)
    |> Enum.into(%{})
  end
end
