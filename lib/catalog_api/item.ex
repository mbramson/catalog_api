defmodule CatalogApi.Item do
  defstruct brand: nil,
            catalog_item_id: nil,
            catalog_price: nil,
            categories: %{}, # TODO Can default be more specific?
            currency: nil,
            has_options: false,
            image_75: nil,
            image_150: nil,
            image_300: nil,
            model: nil,
            options: %{},
            original_points: nil,
            original_price: nil,
            points: nil,
            rank: nil,
            retail_price: nil,
            shipping_estimate: nil,
            tags: %{}
end
