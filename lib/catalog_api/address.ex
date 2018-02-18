defmodule CatalogApi.Address do
  alias CatalogApi.Address
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

  @spec validate(t) :: :ok | {:error, any()}
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
  def validate_field(_field, _value), do: []

  defp validate_field_length(field, value, max_length) when is_binary(value) do
    cond do
      String.length(value) > max_length ->
        [{field, ["cannot be longer than #{max_length} characters"]}]
      true -> []
    end
  end
end
