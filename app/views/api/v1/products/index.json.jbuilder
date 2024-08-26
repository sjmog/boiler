json.array! @products do |product|
  json.(product, :id, :name, :description, :url, :buzz, :validated)
  json.createdAt product.created_at
  json.updatedAt product.updated_at

  json.tags do
    json.array!(product.tags) do |tag|
      json.(tag, :id, :name)
    end
  end

  json.sources do
    json.array!(product.product_sources) do |source|
      json.(source, :id, :source, :name, :description, :url)
      json.createdAt source.created_at
      json.updatedAt source.updated_at
      json.sourcedAt source.sourced_at
      json.meta source.meta
    end
  end
end
