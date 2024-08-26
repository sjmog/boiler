class AddOriginalDataToProductSources < ActiveRecord::Migration[7.2]
  def change
    add_column :product_sources, :original_data, :jsonb
  end
end
