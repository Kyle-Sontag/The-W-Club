class CategoriesController < ApplicationController
  def show
    @category = Category.find(params[:id])
    @products = @category.products.page(params[:page]).per(20)
  end

  def sale
    @category_name = "Sale"
    @category_description = "Discounted Winnipeg Blue Bombers merchandise"
    @products = Product.where.not(sale_price: nil).page(params[:page]).per(20)
  end
end
