defmodule CatalogApi.FormatHelper do
  def is_iso8601_datetime_string(datetime) when is_binary(datetime) do
    case datetime do
      <<_year::bytes-size(4)>>   <> "-" <>
      <<_month::bytes-size(2)>>  <> "-" <>
      <<_day::bytes-size(2)>>    <> "T" <>
      <<_hour::bytes-size(2)>>   <> ":" <>
      <<_minute::bytes-size(2)>> <> ":" <>
      <<_second::bytes-size(2)>> <> "." <>
      <<_rest::bytes-size(6)>>   <> "Z" -> true
      _ -> false
    end
  end
  def is_iso8601_datetime_string(_), do: false

  def is_valid_uuid(uuid) do
    case UUID.info(uuid) do
      {:ok, _} -> true
      _        -> false
    end
  end

  def is_valid_checksum(checksum) do
    case checksum do
      <<_chars::bytes-size(27)>> <> "=" -> :ok
      <<_chars::bytes-size(27)>> <> "%3D" -> :ok
      _ -> {:invalid_checksum, checksum}
    end
  end
end
