class Api::V1::ProductsController < ApplicationController
  before_action :authenticate_user!, only: [:destroy, :restore, :validate]
  before_action :ensure_admin, only: [:destroy, :restore, :validate]

  def index
    @products = Product.includes(:tags, :product_sources)
                       .by_buzz
                       .limit(20)
                       .offset(params[:offset] || 0)
    respond_to do |format|
      format.html
      format.json
    end
  end

  def destroy
    @product = Product.find(params[:id])
    title_and_description = "#{@product.name}: #{@product.description}"

    if @product.destroy
      File.open(Rails.root.join("not_products.txt"), "a") do |file|
        file.puts(title_and_description)
      end
      render json: { message: "Product deleted successfully" }, status: :ok
    else
      render json: { error: "Failed to delete product" }, status: :unprocessable_entity
    end
  end

  def restore
    @product = Product.unscoped.find(params[:id])
    if @product.restore
      remove_from_not_products_file(@product)
      render json: { message: "Product restored successfully" }, status: :ok
    else
      render json: { error: "Failed to restore product" }, status: :unprocessable_entity
    end
  end

  def validate
    @product = Product.find(params[:id])
    if @product.validate_product!
      remove_from_not_products_file(@product)
      add_to_definitely_products_file(@product)
      render json: { message: "Product validated successfully" }, status: :ok
    else
      render json: { error: "Failed to validate product" }, status: :unprocessable_entity
    end
  end

  private

  def ensure_admin
    unless current_user.admin?
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def remove_from_not_products_file(product)
    file_path = Rails.root.join("not_products.txt")
    return unless File.exist?(file_path)

    lines = File.readlines(file_path)
    File.open(file_path, "w") do |file|
      lines.each do |line|
        file.puts(line) unless line.start_with?("#{product.name}:")
      end
    end
  end

  def add_to_definitely_products_file(product)
    File.open(Rails.root.join("definitely_products.txt"), "a") do |file|
      file.puts("#{product.name}: #{product.description}")
    end
  end
end
