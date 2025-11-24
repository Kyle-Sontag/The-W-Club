class ProductsController < ApplicationController
  def index
    # Priority 1: Show featured products
    @products = Product.where(featured: true).limit(20)

    # Priority 2: If no featured products, show sale items
    if @products.empty?
      @products = Product.where.not(sale_price: nil).limit(20)
    end

    # Priority 3: If fewer than 20, fill with regular products
    if @products.count < 20
      remaining = 20 - @products.count
      regular_products = Product.where(featured: false, sale_price: nil).limit(remaining)
      @products = @products + regular_products
    end
  end

  def show
    @product = Product.find(params[:id])
  end
end
