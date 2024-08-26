class Tag < ApplicationRecord
  has_many :product_source_tags
  has_many :tags, through: :product_source_tags
end
