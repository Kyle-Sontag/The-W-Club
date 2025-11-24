class ProductsController < ApplicationController
  def index
    # Shows featured products, if there are no featured products shows 20 random products
    @products = Product.where(featured: true).limit(20)
    @products = Product.order("RANDOM()").limit(20) if @products.empty?
  end

  def show
    @product = Product.find(params[:id])
  end
end
