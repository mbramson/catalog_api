defmodule CatalogApi.Error do
  @moduledoc false

  alias HTTPoison.Response

  alias CatalogApi.Fault

  @spec validate_response_status(Response.t) :: :ok | {:error, {:bad_status, any()}}
  def validate_response_status(%Response{} = response) do
    case response.status_code do
      200 -> :ok
      201 -> :ok
      400 -> {:error, {:catalog_api_fault, extract_fault(response)}}
      status -> {:error, {:bad_status, status}}
    end
  end

  defp extract_fault(%Response{} = response) do
    with {:ok, parsed} <- Poison.decode(response.body),
         {:ok, fault} <- Fault.extract_fault_from_json(parsed) do
      fault
    end
  end
end
