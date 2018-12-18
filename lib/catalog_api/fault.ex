defmodule CatalogApi.Fault do
  @moduledoc """
  Defines the structure and casting of a CatalogApi Fault structure which is
  how CatalogApi reports handled errrs.
  """

  alias CatalogApi.Fault
  alias CatalogApi.StructHelper

  @derive Jason.Encoder
  defstruct detail: "", faultcode: "", faultstring: ""

  @type t :: %Fault{detail: String.t(), faultcode: String.t(), faultstring: String.t()}

  @doc """
  Extracts a `%Fault{}` struct from previously parsed json of the entire fault response.
  """
  @spec extract_fault_from_json(any()) ::
          {:ok, t}
          | {:error, :unparseable_catalog_api_fault}
  def extract_fault_from_json(%{"Fault" => fault_json}), do: {:ok, cast(fault_json)}
  def extract_fault_from_json(_), do: {:error, :unparseable_catalog_api_fault}

  @doc """
  Safely casts some extracted json of the fault itself to a `%Fault{}` struct.
  """
  @spec cast(map()) :: t
  def cast(fault_json) do
    fault_json
    |> StructHelper.filter_keys_not_in_struct(__MODULE__)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
    |> to_struct
  end

  defp to_struct(map), do: struct(Fault, map)
end
