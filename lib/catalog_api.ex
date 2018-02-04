defmodule CatalogApi do

  def current_iso_8601_datetime do
    DateTime.utc_now
    |> DateTime.to_iso8601
  end

  def generate_uuid do
    "b93cee9d-dd04-4154-9b5a-8768971e72b8"
  end
end
