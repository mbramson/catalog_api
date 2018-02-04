defmodule CatalogApi do

  def current_iso_8601_datetime do
    DateTime.utc_now
    |> DateTime.to_iso8601
  end

  def generate_uuid do
    UUID.uuid4()
  end
end
