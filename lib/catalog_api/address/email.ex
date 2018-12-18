defmodule CatalogApi.Address.Email do
  @moduledoc """
  Contains functions for interacting with emails.
  """

  @validation_regex ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

  @spec valid?(String.t) :: boolean()
  def valid?(email) when is_binary(email) do
    Regex.match?(@validation_regex, email)
  end
end
