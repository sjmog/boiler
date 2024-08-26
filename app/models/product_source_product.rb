class ProductSourceProduct < ApplicationRecord
  belongs_to :product_source
  belongs_to :product
end
