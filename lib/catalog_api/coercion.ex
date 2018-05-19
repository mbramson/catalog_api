defmodule CatalogApi.Coercion do
  @moduledoc false

  @spec integer_fields_to_boolean(map(), list(String.t | atom()), boolean()) :: map()
  def integer_fields_to_boolean(map, boolean_fields, return_map \\ true) do
    fields = Enum.map(map, fn {k, v} -> coerce_to_boolean_if_needed(k, v, boolean_fields) end)
    if return_map do
      fields |> Enum.into(%{})
    else
      fields
    end
  end

  @spec coerce_to_boolean_if_needed(String.t | atom(), any(), list(String.t | atom())) :: {String.t, any()}
  defp coerce_to_boolean_if_needed(key, value, boolean_fields) do
    cond do
      key in boolean_fields -> {key, coerce_integer_to_boolean(value)}
      true -> {key, value}
    end
  end

  @spec coerce_integer_to_boolean(any()) :: boolean() | {:error, :failed_boolean_coercion}
  defp coerce_integer_to_boolean(0), do: false
  defp coerce_integer_to_boolean(1), do: true
  defp coerce_integer_to_boolean("0"), do: false
  defp coerce_integer_to_boolean("1"), do: true
  defp coerce_integer_to_boolean(_), do: {:error, :failed_boolean_coercion}

  @spec boolean_fields_to_integer(map(), list(String.t | atom()), boolean()) :: map()
  def boolean_fields_to_integer(map, boolean_fields, return_map \\ true) do
    fields = Enum.map(map, fn {k,v} -> coerce_to_integer_if_needed(k, v, boolean_fields) end)
    if return_map do
      fields |> Enum.into(%{})
    else
      fields
    end
  end

  @spec coerce_to_integer_if_needed(String.t | atom(), any(), list(Strin.t | atom())) ::
    {String.t, any()}
  defp coerce_to_integer_if_needed(key, value, boolean_fields) do
    cond do
      key in boolean_fields -> {key, coerce_boolean_to_integer(value)}
      true -> {key, value}
    end
  end

  @spec coerce_boolean_to_integer(any()) :: integer() | {:error, :failed_integer_coercion}
  defp coerce_boolean_to_integer(true), do: 1
  defp coerce_boolean_to_integer("true"), do: 1
  defp coerce_boolean_to_integer(false), do: 0
  defp coerce_boolean_to_integer("false"), do: 0
  defp coerce_boolean_to_integer(_), do: {:error, :failed_integer_coercion}
end
