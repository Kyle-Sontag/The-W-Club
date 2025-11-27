class ProductsController < ApplicationController
  def index
    # Get featured products
    @featured_products = Product.where(featured: true).limit(20)

    # Get sale products
    @sale_products = Product.where.not(sale_price: nil).limit(20)
  end

  def show
    @product = Product.find(params[:id])
  end
end
