class ProductsController < ApplicationController
  def index
    # Homepage: Show featured products first, then sale items
    @products = Product.where(featured: true).limit(20)

    if @products.empty?
      @products = Product.where.not(sale_price: nil).limit(20)
    end

    if @products.count < 20
      remaining = 20 - @products.count
      regular_products = Product.where(featured: false, sale_price: nil).limit(remaining)
      @products = @products + regular_products
    end

    @categories = Category.all
  end

  def show
    @product = Product.find(params[:id])
  end
end
