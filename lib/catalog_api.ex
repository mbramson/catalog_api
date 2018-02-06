defmodule CatalogApi do

  alias CatalogApi.Url

  def list_available_catalogs() do
    url = Url.url_for("list_available_catalogs")
    HTTPoison.get(url)
  end

end
