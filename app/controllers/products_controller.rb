class ProductsController < ApplicationController
  def index
    # Check for sale filter
    if params[:filter] == "sale"
      @products = Product.where.not(sale_price: nil).order("RANDOM()").limit(20)
      @sale_filter = true
    else
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

    # Get featured and sale products for homepage sections
    @featured_products = Product.where(featured: true).limit(20)
    @sale_products = Product.where.not(sale_price: nil).limit(20)
  end

  def search
    @products = Product.all

    # Search by keyword
    if params[:query].present?
      @products = @products.where("name ILIKE ? OR description ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end

    # Filter by category
    if params[:category_id].present? && params[:category_id] != ""
      @products = @products.where(category_id: params[:category_id])
    end

    # Sort
    @products = case params[:sort]
    when "name_asc"
                  @products.order(:name)
    when "name_desc"
                  @products.order(name: :desc)
    when "price_asc"
                  @products.order(:price)
    when "price_desc"
                  @products.order(price: :desc)
    else
                  @products.order(:name)
    end

    @products = @products.page(params[:page]).per(20)
  end

  def show
    @product = Product.find(params[:id])
    # Store the referring page if it's from a category or search page
    session[:product_return_to] = request.referer if request.referer.present?
  end
end
