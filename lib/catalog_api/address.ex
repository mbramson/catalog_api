defmodule CatalogApi.Address do
  @moduledoc """
  Defines the CatalogApi.Address struct and functions which are responsible for
  validation and interpretation of physical shipping addresses as they relate
  to CatalogApi.
  """
  alias CatalogApi.Address
  alias CatalogApi.Address.Email
  alias CatalogApi.Address.Iso3166
  alias CatalogApi.StructHelper

  defstruct first_name: "",
    last_name: "",
    address_1: "",
    address_2: "",
    address_3: "",
    city: "",
    state_province: "",
    postal_code: "",
    country: "",
    email: "",
    phone_number: ""

  @type t :: %Address{}

  @spec validate_params(map()) :: :ok | {:error, {:invalid_address, list()}}
  def validate_params(params) when is_map(params) do
    with {:ok, address_struct} <- convert_params_to_struct(params) do
      validate(address_struct)
    end
  end

  defp convert_params_to_struct(params) do
    with {:ok, filtered_params} <- filter_disallowed_fields(params),
         {:ok, atom_params} <- keys_to_atoms(filtered_params) do
      to_struct(atom_params)
    end
  end

  @spec keys_to_atoms(map()) :: %{optional(atom()) => any()}
  defp keys_to_atoms(fields) do
    {:ok, Enum.map(fields, fn {k, v} -> {ensure_atom(k), v} end)}
  end

  defp ensure_atom(value) when is_atom(value), do: value
  defp ensure_atom(value) when is_binary(value), do: String.to_atom(value)

  @spec filter_disallowed_fields(%{optional(String.t) => any()}) :: list({String.t, any()})
  defp filter_disallowed_fields(fields) do
    {:ok, allowed_fields_atoms} = StructHelper.allowed_fields(Address)
    {:ok, allowed_fields_strings} = StructHelper.allowed_fields_as_strings(Address)
    allowed_fields = allowed_fields_atoms ++ allowed_fields_strings
    {:ok, Enum.filter(fields, fn {k, _} -> k in allowed_fields end)}
  end

  defp to_struct(map) do
    {:ok, struct(Address, map)}
  end

  @doc """
  Validates an address struct to ensure that its values will not be rejected by
  CatalogApi endpoints. This ensures that an error can be thrown before the
  CatalogApi endpoint is actually hit.

  If the Address struct is valid, :ok is returned.

  If there are validation errors, than an error tuple is returned which
  enumerates the field specific errors.

  ## Examples

      iex> address = %CatalogApi.Address{
      ...>   first_name: "Jo",
      ...>   last_name: "Bob",
      ...>   address_1: "123 Street Road",
      ...>   city: "Cleveland",
      ...>   state_province: "OH",
      ...>   postal_code: "44444",
      ...>   country: "US"}
      ...> CatalogApi.Address.validate(address)
      :ok

      iex> address = %CatalogApi.Address{
      ...>   first_name: "Jo",
      ...>   last_name: "Bob",
      ...>   address_1: "123 Street Road",
      ...>   city: "",
      ...>   state_province: "OH",
      ...>   postal_code: "44444",
      ...>   country: "AJ"}
      ...> CatalogApi.Address.validate(address)
      {:error, {:invalid_address, [{:country, ["country code must be valid ISO 3166-1 alpha 2 country code"]}, {:city, ["cannot be blank"]}]}}

  """
  @spec validate(t) :: :ok | {:error, {:invalid_address, list()}}
  def validate(%Address{} = address) do
    {:ok, allowed_fields} = StructHelper.allowed_fields(Address)
    errors = allowed_fields
      |> Enum.reduce([], fn field, acc ->
           validate_field(field, Map.fetch!(address, field)) ++ acc
         end)

    case errors do
      [] -> :ok
      errors -> {:error, {:invalid_address, errors}}
    end
  end

  # TODO: Think about validation for state_province. Through poking the API,
  # this can be anywhere between 1 and 50 alphanumeric characters despite the
  # CatalogApi docstring saying that it must be 2 characters for US states. I
  # guess outside of the US there is no such validation restriction? Maybe we
  # can specially validate this field if the country is "US"

  @doc """
  Validates a specific address field in the context of what is valid as input
  to a CatalogApi address.
  """
  @spec validate_field(atom(), any()) :: list()
  def validate_field(:first_name, ""), do: [{:first_name, ["cannot be blank"]}]
  def validate_field(:first_name, first_name) when is_binary(first_name) do
    validate_field_length(:first_name, first_name, 40)
  end
  def validate_field(:first_name, _), do: [{:first_name, ["must be a string"]}]
  def validate_field(:last_name, ""), do: [{:last_name, ["cannot be blank"]}]
  def validate_field(:last_name, last_name) when is_binary(last_name) do
    validate_field_length(:last_name, last_name, 40)
  end
  def validate_field(:last_name, _), do: [{:last_name, ["must be a string"]}]
  def validate_field(:address_1, ""), do: [{:address_1, ["cannot be blank"]}]
  def validate_field(:address_1, address_1) when is_binary(address_1) do
    validate_field_length(:address_1, address_1, 75)
  end
  def validate_field(:address_1, _), do: [{:address_1, ["must be a string"]}]
  def validate_field(:address_2, address_2) when is_binary(address_2) do
    validate_field_length(:address_2, address_2, 60)
  end
  def validate_field(:address_2, _), do: [{:address_2, ["must be a string"]}]
  def validate_field(:address_3, address_3) when is_binary(address_3) do
    validate_field_length(:address_3, address_3, 60)
  end
  def validate_field(:address_3, _), do: [{:address_3, ["must be a string"]}]
  def validate_field(:city, ""), do: [{:city, ["cannot be blank"]}]
  def validate_field(:city, city) when is_binary(city) do
    validate_field_length(:city, city, 40)
  end
  def validate_field(:city, _), do: [{:city, ["must be a string"]}]
  def validate_field(:state_province, ""), do: [{:state_province, ["cannot be blank"]}]
  def validate_field(:state_province, state_province) when is_binary(state_province) do
    validate_field_length(:state_province, state_province, 50)
  end
  def validate_field(:state_province, _), do: [{:state_province, ["must be a string"]}]
  def validate_field(:postal_code, ""), do: [{:postal_code, ["cannot be blank"]}]
  def validate_field(:postal_code, postal_code) when is_binary(postal_code) do
    validate_field_length(:postal_code, postal_code, 15)
  end
  def validate_field(:postal_code, _), do: [{:postal_code, ["must be a string"]}]
  def validate_field(:country, ""), do: [{:country, ["cannot be blank"]}]
  def validate_field(:country, country) when is_binary(country) do
    case Iso3166.validate(country) do
      :ok -> []
      :error -> [{:country, ["country code must be valid ISO 3166-1 alpha 2 country code"]}]
    end
  end
  def validate_field(:country, _), do: [{:country, ["must be a string"]}]
  def validate_field(:email, ""), do: []
  def validate_field(:email, email) when is_binary(email) do
    cond do
      String.length(email) > 254 -> [{:email, ["cannot be longer than 254 characters"]}]
      Email.valid?(email) -> []
      true -> [{:email, ["must be a valid email"]}]
    end
  end
  def validate_field(:email, _), do: [{:email, ["must be a string"]}]
  def validate_field(:phone_number, ""), do: []
  def validate_field(:phone_number, phone_number) when is_binary(phone_number) do
    validate_field_length(:phone_number, phone_number, 20)
  end
  def validate_field(:phone_number, _), do: [{:phone_number, ["must be a string"]}]
  def validate_field(_field, _value), do: []

  defp validate_field_length(field, value, max_length) when is_binary(value) do
    cond do
      String.length(value) > max_length ->
        [{field, ["cannot be longer than #{max_length} characters"]}]
      true -> []
    end
  end
end
