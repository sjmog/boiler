class ProductSourceTag < ApplicationRecord
  belongs_to :product_source
  belongs_to :tag
end
