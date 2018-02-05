defmodule CatalogApi.FormatHelper do
  def is_iso8601_datetime_string(datetime) when is_binary(datetime) do
    case datetime do
      <<_year::bytes-size(4)>>   <> "-" <>
      <<_month::bytes-size(2)>>  <> "-" <>
      <<_day::bytes-size(2)>>    <> "T" <>
      <<_hour::bytes-size(2)>>   <> ":" <>
      <<_minute::bytes-size(2)>> <> ":" <>
      <<_second::bytes-size(2)>> <> "." <>
      <<_rest::bytes-size(6)>>   <> "Z" -> :ok

      <<_year::bytes-size(4)>>   <> "-"   <>
      <<_month::bytes-size(2)>>  <> "-"   <>
      <<_day::bytes-size(2)>>    <> "T"   <>
      <<_hour::bytes-size(2)>>   <> "%3A" <>
      <<_minute::bytes-size(2)>> <> "%3A" <>
      <<_second::bytes-size(2)>> <> "."   <>
      <<_rest::bytes-size(6)>>   <> "Z" -> :ok

      _ -> {:invalid_datetime, datetime}
    end
  end
  def is_iso8601_datetime_string(datetime), do: {:invalid_datetime, datetime}

  def is_valid_uuid(uuid) do
    case UUID.info(uuid) do
      {:ok, _} -> :ok
      error    -> error
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
