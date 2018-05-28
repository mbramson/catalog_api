defmodule CatalogApi do
  @moduledoc """
  Contains top-level API functions for making requests to CatalogAPI.
  """

  alias CatalogApi.Address
  alias CatalogApi.CartItem
  alias CatalogApi.Category
  alias CatalogApi.Coercion
  alias CatalogApi.Error
  alias CatalogApi.Fault
  alias CatalogApi.Item
  alias CatalogApi.Url

  # TODO add param validation
  # TODO add response parsing

  @doc """
  Returns a list of the domains tied to the used credentials and those domain's
  sockets.

  A domain is something tied to a specific account. This includes information about the account in general.

  A domain (and by extension an account) can have multiple sockets. Each socket
  represents a different catalog of items, point exchange rates, currency,
  language, among other information.
  """
  def list_available_catalogs() do
    url = Url.url_for("list_available_catalogs")

    with {:ok, response} <- HTTPoison.get(url),
         :ok <- Error.validate_response_status(response),
         {:ok, json} <- parse_json(response.body) do
      {:ok, json}
    end
  end

  @doc """
  Returns a list of all item categories for the given socket_id.

  Requires a `socket_id`.

  There are two optional parameters which can be supplied:

  - `is_flat`: If true, the returned categories are in a flat list. If false or
    not supplied as an option, then the categories are returned in a nested
    format.

  - `tags`: Can specify tags which narrow down the categories. The official
    documentation explains: We have the ability to "tag" certain items based on
    custom criteria that is unique to our clients. If we setup these tags on your
    catalog, you can pass a tag name to receive back only categories that contain
    items matching the tag.
  """
  def catalog_breakdown(socket_id, opts \\ []) do
    allowed = [:is_flat, :tag]
    {:ok, optional_params} = filter_optional_params([], opts, allowed)
    required_params = %{socket_id: socket_id}

    params =
      optional_params
      |> Map.merge(required_params)
      |> Coercion.boolean_fields_to_integer([:is_flat])

    url = Url.url_for("catalog_breakdown", params)

    with {:ok, response} <- HTTPoison.get(url),
         :ok <- Error.validate_response_status(response),
         {:ok, json} <- parse_json(response.body),
         {:ok, categories} <- Category.extract_categories_from_json(json) do
      {:ok, categories}
    end
  end

  @valid_search_catalog_keys ~w(socket_id name search category_id min_points
    max_points min_price max_price max_rank tag page per_page sort
    catalog_item_ids)

  @doc """
  Searches for CatalogApi items which meet the specified criteria.

  Requires a `socket_id` and a list of criteria that returned items must match.
  All search parameters are optional.

  Allowed search parameters:
  - `name`: The name of the item.
  - `search`: Matches the name, description or model of items.
  - `category_id`: Matches only items within this category_id. (This includes
    any child categories of the category_id.) The category_id comes from the
    catalog_breakdown method.
  - `min_points`: Matches only items that cost a greater or equal number of points.
  - `max_points`: Matches only items that cost a lesser or equal number of points.
  - `min_price`: Matches only items that cost a great or equal amount.
  - `max_price`: Matches only items that cost a lesser or equal amount.
  - `max_rank`: Matches only items with a rank lesser than or equal to the
    specified value. The rank of an item indicates its popularity between 1 and
    1000. A smaller value indicates a more popular item.
  - `tag`: Matches items with custom tags.
  - `page`: The page to retrieve.
  - `per_page`: The quantity of items to retrieve per page. Must be between 1
    and 50. The default is 10 if this parameter is not specified
  - `sort`: The method to use to sort the results. Allowed values are:
    - `"points desc"` - Will return items worth the most points first.
    - `"points asc"` - Will return items worth the least points first.
    - `"rank asc"`: Will return items with the most popular ones first.
    - `"score desc"` (default): Will return items with the the most relevant
      ones first.  Sorting by score only makes sense when you are searching with
      the "name" or "search" arguments.
    - `"random asc"`: Will return the items in random order.
  - `catalog_item_ids`: Accepts an array of items. Matches only items that ar
    in the given list
  """
  @spec search_catalog(integer(), map()) ::
          {:ok, %{items: Item.t(), page_info: map()}}
          | {:error, {:bad_status, integer()}}
          | {:error, {:catalog_api_fault, Error.extracted_fault()}}
          | {:error, Poison.ParseError.t()}
  def search_catalog(socket_id, opts \\ %{}) do
    required_params = %{socket_id: socket_id}
    params = merge_required_filter_invalid(opts, required_params, @valid_search_catalog_keys)

    # TODO validate each search parameter when used

    url = Url.url_for("search_catalog", params)

    with {:ok, response} <- HTTPoison.get(url),
         :ok <- Error.validate_response_status(response),
         {:ok, json} <- parse_json(response.body),
         {:ok, items} <- Item.extract_items_from_json(json),
         {:ok, page_info} <- extract_page_info(json) do
      {:ok, %{items: items, page_info: page_info}}
    end
  end

  defp extract_page_info(%{
         "search_catalog_response" => %{"search_catalog_result" => %{"pager" => page_info}}
       }) do
    {:ok, page_info}
  end

  defp extract_page_info(_), do: {:error, :unparseable_catalog_api_page_info}

  @doc """
  Retrieves information about a specific CatalogApi item.

  Requires a socket_id and an item_id.

  Returns a `%CatalogApi.Item{}` struct upon a successful request.

  If the item does not exist, this returns an error tuple of the format
  `{:error, :item_not_found}`
  """
  @spec view_item(integer(), integer() | String.t()) ::
          {:ok, %{item: Item.t()}}
          | {:error, {:bad_status, integer()}}
          | {:error, {:catalog_api_fault, Error.extracted_fault()}}
          | {:error, Poison.ParseError.t()}
          | {:error, :item_not_found}
  def view_item(socket_id, catalog_item_id) do
    params = %{socket_id: socket_id, catalog_item_id: catalog_item_id}
    url = Url.url_for("view_item", params)

    with {:ok, response} <- HTTPoison.get(url),
         :ok <- Error.validate_response_status(response),
         {:ok, json} <- parse_json(response.body),
         {:ok, item} <- Item.extract_items_from_json(json) do
      {:ok, %{item: item}}
    else
      {:error, {:catalog_api_fault, %Fault{faultstring: "Invalid catalog_item_id:" <> _}}} ->
        {:error, :item_not_found}

      other ->
        other
    end
  end

  @doc """
  Sets the shipping address for the given user's cart.

  Requires a socket_id, an external_user_id, and a map of address parameters.

  The list of available address parameters can be found in the module
  documentation for CatalogApi.Address.

  You can use a `%CatalogApi.Address{}` struct for the address parameters
  argument.

  If the address parameters are not valid as per
  `CatalogApi.Address.validate_params/1`, then this function will return an error
  tuple without making a call to the CatalogApi endpoint.
  """
  @spec cart_set_address(integer(), integer(), map()) ::
          {:ok, %{description: String.t()}}
          | {:error, Address.invalid_address_error()}
          | {:error, {:bad_status, integer()}}
          | {:error, {:catalog_api_fault, Error.extracted_fault()}}
          | {:error, Poison.ParseError.t()}
          | {:error, :unparseable_response_description}
  def cart_set_address(socket_id, external_user_id, address = %Address{}) do
    address_params = Map.from_struct(address)
    cart_set_address(socket_id, external_user_id, address_params)
  end

  def cart_set_address(socket_id, external_user_id, address_params) do
    with :ok <- Address.validate_params(address_params) do
      params =
        address_params
        |> Map.merge(%{socket_id: socket_id, external_user_id: external_user_id})

      url = Url.url_for("cart_set_address", params)

      with {:ok, response} <- HTTPoison.get(url),
           :ok <- Error.validate_response_status(response),
           {:ok, json} <- parse_json(response.body),
           {:ok, description} <- extract_description(json) do
        {:ok, %{description: description}}
      end
    end
  end

  def cart_set_item_quantity(socket_id, external_user_id, catalog_item_id, option_id, quantity) do
    # TODO add option_id to optional params
    params = %{
      socket_id: socket_id,
      external_user_id: external_user_id,
      catalog_item_id: catalog_item_id,
      option_id: option_id,
      quantity: quantity
    }

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

    required_params = %{
      socket_id: socket_id,
      external_user_id: external_user_id,
      catalog_item_id: catalog_item_id
    }

    params = Map.merge(optional_params, required_params)

    url = Url.url_for("cart_add_item", params)

    with {:ok, response} <- HTTPoison.get(url),
         :ok <- Error.validate_response_status(response),
         {:ok, json} <- parse_json(response.body),
         {:ok, description} <- extract_description(json) do
      {:ok, %{description: description}}
    end
  end

  @spec extract_description(map()) ::
          {:ok, any()}
          | {:error, :unparseable_response_description}
  defp extract_description(%{
         "cart_add_item_response" => %{"cart_add_item_result" => %{"description" => description}}
       }) do
    {:ok, description}
  end

  defp extract_description(%{
         "cart_set_address_response" => %{
           "cart_set_address_result" => %{"description" => description}
         }
       }) do
    {:ok, description}
  end
  defp extract_description(%{
         "cart_remove_item_response" => %{
           "cart_remove_item_result" => %{"description" => description}
         }
       }) do
    {:ok, description}
  end

  defp extract_description(_), do: {:error, :unparseable_response_description}

  @doc """
  Removes the specified item from the user's cart.

  Optional parameters include:

  - `option_id`: If there are multiple versions of a single item id with
    different options, this can be used to only remove items with the given
    option.
  - `quantity`: The quantity of the given item to remove. If this is not
    specified, then all items of this type are removed from the cart.

  If the item doesn't actually exist or was not in the given user's cart then
  this still returns a response indicating that the operation was successful.
  This is a behavior of the CatalogAPI API itself and not specific to this
  `CatalogApi` library.

  ## Example

      iex> CatalogApi.cart_remove_item(1061, 200, 123456)
      {:ok, %{description: "Item quantity decreased."}}
  """
  def cart_remove_item(socket_id, external_user_id, catalog_item_id, opts \\ []) do
    allowed = [:option_id, :quantity]
    {:ok, optional_params} = filter_optional_params([], opts, allowed)

    required_params = %{
      socket_id: socket_id,
      external_user_id: external_user_id,
      catalog_item_id: catalog_item_id
    }

    params = Map.merge(optional_params, required_params)

    url = Url.url_for("cart_remove_item", params)

    with {:ok, response} <- HTTPoison.get(url),
         :ok <- Error.validate_response_status(response),
         {:ok, json} <- parse_json(response.body),
         {:ok, description} <- extract_description(json) do
      {:ok, %{description: description}}
    end
  end

  def cart_empty(socket_id, external_user_id) do
    params = %{socket_id: socket_id, external_user_id: external_user_id}
    url = Url.url_for("cart_empty", params)
    HTTPoison.get(url)
  end

  @doc """
  Returns the contents of the specified user's shopping cart.

  The return contains the list of items in the cart casted as
  `CatalogApi.CartItem{}` structs.

  Also returns the address associated with the cart in the form of a
  `%CatalogApi.Address{}` struct. If there is no address associated with the
  given cart, then this still returns a `%CatalogApi.Address{}` struct, but the
  keys are all empty strings.

  The return also returns a map under the :status key which contains some
  information about the status of the cart. The keys contained in this map are
  as follows:

  - `error`: An error string describing the error. When there is no error, this
    is "".
  - `has_item_errors`: Boolean indicating whether the cart contains errors
    specific to items.
  - `is_valid`: Boolean indicating whether the cart is valid. If this is false,
    than this cart cannot be used to place an order
  - `needs_address`: Boolean indicating whether the cart is missing an address.
  - `locked`: Boolean indicating whether the cart is locked or not. If the cart
    is locked, an order can be placed with it, but it cannot be altered.
  - `cart_version`: A String uuid indicating the current version of the cart.
    This can be used to ensure that the cart which is being used to place an
    order has not changed since the application's state has been updated.

  ## Examples

      iex> CatalogApi.cart_view(1000, 500)
      {:ok,
       %{
         address: %CatalogApi.Address{
           address_1: "123 st",
           address_2: "",
           address_3: "",
           city: "cleveland",
           country: "US",
           email: "",
           first_name: "john",
           last_name: "gotty",
           phone_number: "",
           postal_code: "44444",
           state_province: "OH"
         },
         items: [
           %CatalogApi.CartItem{
             cart_price: "50.00",
             catalog_item_id: 3870422,
             catalog_points: 1000,
             catalog_price: "50.00",
             currency: "USD",
             error: "",
             image_uri: "https://dck0i7x64ch95.cloudfront.net/asset/1/8/9/189373b3846ed28cb788f1051b2af5db_75_.jpg",
             is_available: true,
             is_valid: true,
             name: "Marshalls® eGift Card $50",
             points: 1000,
             quantity: 2,
             retail_price: "50.00",
             shipping_estimate: "0.00"
           }
         ],
         status: %{
           cart_version: "5dd19634-e2b9-4c35-a9ec-9453a59ec22b",
           error: "",
           has_item_errors: false,
           is_valid: true,
           locked: false,
           needs_address: false
         }
       }}

  In the event that the cart is empty, the response will look a bit different:

      iex> CatalogApi.cart_view(1000, 99999)
      {:ok,
       %{
         address: %CatalogApi.Address{
           address_1: "",
           address_2: "",
           address_3: "",
           city: "",
           country: "",
           email: "",
           first_name: "",
           last_name: "",
           phone_number: "",
           postal_code: "",
           state_province: ""
         },
         items: [],
         status: :cart_status_unavailable
       }}
  """
  @spec cart_view(integer(), integer()) ::
          {:ok, %{items: list(Item.t()), status: map() | :cart_status_unavailable}}
          | {:error, atom()}
  def cart_view(socket_id, external_user_id) do
    params = %{socket_id: socket_id, external_user_id: external_user_id}
    url = Url.url_for("cart_view", params)

    with {:ok, response} <- HTTPoison.get(url),
         :ok <- Error.validate_response_status(response),
         {:ok, json} <- parse_json(response.body),
         {:ok, items} <- CartItem.extract_items_from_json(json),
         {:ok, address} <- Address.extract_address_from_json(json),
         {:ok, cart_status} <- extract_cart_status(json) do
      {:ok, %{items: items, address: address, status: cart_status}}
    end
  end

  @spec extract_cart_status(map()) :: {:ok, map()} | {:error, :unparseable_response_cart_status}
  defp extract_cart_status(%{"cart_view_response" => %{"cart_view_result" => params}}) do
    boolean_fields = ~w(has_item_errors is_valid locked needs_address)

    case params |> Coercion.integer_fields_to_boolean(boolean_fields) do
      %{
        "error" => error,
        "has_item_errors" => has_item_errors,
        "is_valid" => is_valid,
        "cart_version" => cart_version,
        "locked" => locked,
        "needs_address" => needs_address
      } ->
        {:ok,
         %{
           error: error,
           has_item_errors: has_item_errors,
           is_valid: is_valid,
           cart_version: cart_version,
           locked: locked,
           needs_address: needs_address
         }}

      _ ->
        {:ok, :cart_status_unavailable}
    end
  end

  defp extract_cart_status(_), do: {:error, :unparseable_response_cart_status}

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
    locked =
      case locked do
        true -> "1"
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

  There is one allowed optional parameter:

  - cart_version: If this is supplied, this method will only succeed if the
    passed version matches the version of the current cart. This can be used to
    ensure that the state of the users cart in your application has not become
    stale before the order is placed.

  If the `cart_order_place/3` is invoked with cart version which does not match
  the current version of the cart, then an error tuple will be returned of the
  format `{:error, :stale_cart_version}`. This can be useful to ensure that the
  order being placed matches what the consuming application believes the current
  state of the cart to be,
  """
  @spec cart_order_place(integer(), integer(), Keyword.t()) ::
          {:ok, map()}
          | {:error, :cart_not_found}
          | {:error, :no_shipping_address}
          | {:error, :stale_cart_version}
          | {:error, {:bad_status, integer()}}
          | {:error, {:catalog_api_fault, Error.extracted_fault()}}
          | {:error, Poison.ParseError.t()}
  def cart_order_place(socket_id, external_user_id, opts \\ []) do
    allowed = [:cart_version]
    {:ok, optional_params} = filter_optional_params([], opts, allowed)

    required_params = %{socket_id: socket_id, external_user_id: external_user_id}
    params = Map.merge(optional_params, required_params)

    url = Url.url_for("cart_order_place", params)

    with {:ok, response} <- HTTPoison.get(url),
         :ok <- Error.validate_response_status(response),
         {:ok, json} <- parse_json(response.body) do
      {:ok, json}
    else
      {:error, {:catalog_api_fault, %Fault{faultstring: "Cart not found."}}} ->
        {:error, :cart_not_found}

      {:error,
       {:catalog_api_fault, %Fault{faultstring: "A shipping address must be added to the cart."}}} ->
        {:error, :no_shipping_address}

      {:error,
       {:catalog_api_fault,
        %Fault{faultstring: "The given cart version does not match the cart."}}} ->
        {:error, :stale_cart_version}

      other ->
        other
    end
  end

  def order_place() do
    # TODO this allows for an order placement all at once. Might not be needed.
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
    %{per_page: per_page, page: page} = Keyword.merge(defaults, opts) |> Enum.into(%{})

    # TODO: validate that per_page is at most 50.

    params = %{external_user_id: external_user_id, per_page: per_page, page: page}

    url = Url.url_for("order_list", params)
    HTTPoison.get(url)
  end

  defp parse_json(json) do
    Poison.decode(json)
  end

  defp merge_required_filter_invalid(opts, required, valid_keys) do
    opts
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

  @spec filter_optional_params(Keyword.t(), Keyword.t(), list(atom())) ::
          {:ok, %{optional(atom()) => any()}} | {:error, :invalid_argument}
  defp filter_optional_params(defaults, opts, allowed)
       when is_list(defaults) and is_list(opts) and is_list(allowed) do
    filtered_params =
      defaults
      |> Keyword.merge(opts)
      |> Enum.filter(fn {k, _} -> k in allowed end)
      |> Enum.into(%{})

    {:ok, filtered_params}
  end

  defp filter_optional_params(_, _, _), do: {:error, :invalid_argument}
end
