class ProductSource < ApplicationRecord
  belongs_to :product
  belongs_to :validated_by, class_name: "User", optional: true

  has_many :product_source_tags
  has_many :tags, through: :product_source_tags
end
