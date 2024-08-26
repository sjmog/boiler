class Api::V1::ProductSourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def index
    product = Product.find(params[:product_id])
    render json: product.product_sources
  end

  def approve
    product_source = ProductSource.find(params[:id])
    product = Product.find(params[:product_id])

    ActiveRecord::Base.transaction do
      product_source.update(validated: true, validated_by: current_user)

      if params[:replaceTitle]
        product.update(name: product_source.name)
      end

      if params[:replaceDescription]
        product.update(description: product_source.description)
      end

      if params[:replaceUrl]
        product.update(url: product_source.url)
      end

      product.update_buzz
    end

    render json: { success: true }
  end

  def disapprove
    product_source = ProductSource.find(params[:id])
    product = Product.find(params[:product_id])
    product_source.update(validated: false, validated_by: nil)
    product.update_buzz
    render json: { success: true }
  end

  private

  def ensure_admin
    render json: { error: "Not authorized" }, status: :unauthorized unless current_user.admin?
  end
end
