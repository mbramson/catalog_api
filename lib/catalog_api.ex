defmodule CatalogApi do

  alias CatalogApi.Url
  alias CatalogApi.Item

  # TODO add param validation
  # TODO add response parsing

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
    with {:ok, response} <- HTTPoison.get(url),
         :ok <- validate_status(response),
         {:ok, json} <- parse_json(response.body),
         {:ok, items} <- Item.extract_items_from_json(json),
         {:ok, page_info} <- extract_page_info(json) do
      {:ok, %{items: items, page_info: page_info}}
    end
  end

  defp extract_page_info(%{"search_catalog_response" =>
    %{"search_catalog_result" =>
      %{"pager" => page_info}}}) do
    {:ok, page_info}
  end
  defp extract_page_info(_), do: {:error, :unparseable_catalog_api_page_info}

  def view_item(socket_id, catalog_item_id) do
    params = %{socket_id: socket_id, catalog_item_id: catalog_item_id}
    url = Url.url_for("view_item", params)
    with {:ok, response} <- HTTPoison.get(url),
         :ok <- validate_status(response),
         {:ok, json} <- parse_json(response.body),
         {:ok, item} <- Item.extract_items_from_json(json) do
      {:ok, %{item: item}}
    end
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

  @doc """
  Adds the specified catalog item id to the user's shopping cart.

  Optional parameters include:

  - option_id (optional): The id of the option for the item that should be added to the
    cart. If there are multiple options (such as color, size, etc.) for a given
    item, this allows the correct option to be added. This parameter is optional.
  - quantity (default: 1): The quantity of the given item to add to the cart.
  """
  def cart_add_item(socket_id, external_user_id, catalog_item_id, opts \\ []) do
    defaults = [quantity: 1]
    allowed = [:option_id, :quantity]
    {:ok, optional_params} = filter_optional_params(defaults, opts, allowed)

    required_params = %{socket_id: socket_id,
                        external_user_id: external_user_id,
                        catalog_item_id: catalog_item_id}
    params = Map.merge(optional_params, required_params)

    url = Url.url_for("cart_add_item", params)
    with {:ok, response} <- HTTPoison.get(url),
         :ok <- validate_status(response),
         {:ok, json} <- parse_json(response.body),
         {:ok, description} <- extract_description(json) do
      {:ok, %{description: description}}
    end
  end

  @spec extract_description(map()) :: {:ok, any()} | {:error, :unparseable_response_description}
  defp extract_description(
    %{"cart_add_item_response" =>
      %{"cart_add_item_result" =>
        %{"description" => description}}}) do
    {:ok, description}
  end
  defp extract_description(_), do: {:error, :unparseable_response_description}

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

  @spec validate_status(%{status_code: any()}) :: :ok | {:error, {:bad_status, any()}}
  defp validate_status(response) do
    case response.status_code do
      200 -> :ok
      status -> {:error, {:bad_status, status}}
    end
  end

  defp parse_json(json) do
    try do
      {:ok, Poison.decode!(json)}
    rescue
      _ -> {:error, :response_json_parse_error}
    end
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

  @spec filter_optional_params(Keyword.t, Keyword.t, list(atom())) ::
    {:ok, %{optional(atom()) => any()}} | {:error, :invalid_argument}
  defp filter_optional_params(defaults, opts, allowed)
    when is_list(defaults) and is_list(opts) and is_list(allowed) do
    filtered_params = defaults
      |> Keyword.merge(opts)
      |> Enum.filter(fn {k, _} -> k in allowed end)
      |> Enum.into(%{})
    {:ok, filtered_params}
  end
  defp filter_optional_params(_, _, _), do: {:error, :invalid_argument}

end
