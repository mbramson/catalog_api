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
    cond do
      String.length(first_name) > 40 ->
        [{:first_name, ["cannot be longer than 40 characters"]}]
      true -> []
    end
  end
  def validate_field(:first_name, _), do: [{:first_name, ["must be a string"]}]
  def validate_field(:last_name, ""), do: [{:last_name, ["cannot be blank"]}]
  def validate_field(:last_name, last_name) when is_binary(last_name) do
    cond do
      String.length(last_name) > 40 ->
        [{:last_name, ["cannot be longer than 40 characters"]}]
      true -> []
    end
  end
  def validate_field(:last_name, _), do: [{:last_name, ["must be a string"]}]
  def validate_field(_field, _value), do: []

end
