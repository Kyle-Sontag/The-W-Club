class CategoriesController < ApplicationController
  def show
    @category = Category.find(params[:id])
    @products = @category.products

    # Search by keyword
    if params[:query].present?
      @products = @products.where("name ILIKE ? OR description ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end

    # Filter by sale items
    if params[:filter] == "sale"
      @products = @products.where.not(sale_price: nil)
    end

    # Filter by recently updated (within 3 days)
    if params[:filter] == "recent"
      @products = @products.where("updated_at >= ?", 3.days.ago)
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

  def sale
    @category_name = "Sale"
    @category_description = "Discounted Winnipeg Blue Bombers merchandise"
    @products = Product.where.not(sale_price: nil)

    # Search by keyword
    if params[:query].present?
      @products = @products.where("name ILIKE ? OR description ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end

    # Filter by category
    if params[:category_id].present? && params[:category_id] != ""
      @products = @products.where(category_id: params[:category_id])
    end

    # Filter by recently updated
    if params[:filter] == "recent"
      @products = @products.where("updated_at >= ?", 3.days.ago)
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
end
