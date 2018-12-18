defmodule CatalogApi.Error do
  @moduledoc false

  alias HTTPoison.Response

  alias CatalogApi.Fault

  @spec validate_response_status(Response.t()) ::
          :ok
          | {:error, {:bad_status, integer()}}
          | {:error, {:catalog_api_fault, extracted_fault}}
  def validate_response_status(%Response{} = response) do
    case response.status_code do
      200 -> :ok
      201 -> :ok
      400 -> {:error, {:catalog_api_fault, extract_fault(response)}}
      status -> {:error, {:bad_catalog_api_status, status}}
    end
  end

  @type extracted_fault ::
          Fault.t()
          | {:error, Jason.DecodeError.t()}
          | {:error, :unparseable_catalog_api_fault}

  @spec extract_fault(Response.t()) :: extracted_fault
  defp extract_fault(%Response{} = response) do
    with {:ok, parsed} <- Jason.decode(response.body),
         {:ok, fault} <- Fault.extract_fault_from_json(parsed) do
      fault
    end
  end
end
