defmodule CatalogApi.FixtureHelper do

  @response_headers [
    {"Access-Control-Allow-Methods", "GET"},
    {"Access-Control-Allow-Origin", "*"},
    {"Content-Type", "application/json"},
    {"Date", "Sat, 17 Feb 2018 23:03:56 GMT"},
    {"Server", "nginx/1.1.19"},
    {"Content-Length", "113"},
    {"Connection", "keep-alive"}
  ]

  def retrieve_fixture(fixture_name) do
    file_path = File.cwd! <> "/test/fixtures/#{fixture_name}"

    case File.read(file_path) do
      {:ok, file} -> file
      {:error, code} -> raise "Could not load fixture file: #{file_path}, error: #{code}"
    end
  end

  def retrieve_json_fixture(fixture_name) do
    retrieve_fixture("#{fixture_name}.json") |> Poison.decode!
  end

  def retrieve_json_response(fixture_name, status_code \\ 200) do
    %HTTPoison.Response{
      body: retrieve_fixture("#{fixture_name}.json"),
      headers: @response_headers,
      request_url: "",
      status_code: status_code
    }
  end
end
