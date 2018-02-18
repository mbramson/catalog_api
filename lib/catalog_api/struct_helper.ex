defmodule CatalogApi.StructHelper do
  @moduledoc false

  @spec filter_keys_not_in_struct(%{optional(String.t) => any()}, atom()) ::
    %{optional(String.t) => any()}
    | {:error, {:struct_not_defined_for, atom()}}
  def filter_keys_not_in_struct(map, module) do
    with {:ok, allowed_fields} <- allowed_fields_as_strings(module) do
      map
      |> Enum.filter(fn {k, _v} -> k in allowed_fields end)
      |> Enum.into(%{})
    end
  end

  @spec allowed_fields_as_strings(atom()) ::
    {:ok, list(String.t)}
    | {:error, {:struct_not_defined_for, atom()}}
  defp allowed_fields_as_strings(module) when is_atom(module) do
    with {:ok, fields} <- allowed_fields(module) do
      {:ok, Enum.map(fields, &(Atom.to_string(&1)))}
    end
  end

  @spec allowed_fields(atom()) ::
    {:ok, list(atom())}
    | {:error, {:struct_not_defined_for, atom()}}
  def allowed_fields(module) when is_atom(module) do
    try do
      fields = module
        |> struct
        |> Map.keys
        |> Enum.filter(&(&1 != :__struct__))
      {:ok, fields}
    rescue
      UndefinedFunctionError -> {:error, {:struct_not_defined_for, module}}
    end
  end
end
