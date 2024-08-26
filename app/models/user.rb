class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :product_source_products, foreign_key: :validated_by_id
  has_many :validated_product_sources, through: :product_source_products, source: :product_source
end
