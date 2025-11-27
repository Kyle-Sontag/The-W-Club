class Admin::ProductsController < Admin::BaseController
  def index
    @products = Product.all

    # Search by name
    if params[:search].present?
      @products = @products.where("name ILIKE ?", "%#{params[:search]}%")
    end

    # Filter by category or sale items
    if params[:category_id].present?
      if params[:category_id] == "sale"
        @products = @products.where.not(sale_price: nil)
      else
        @products = @products.where(category_id: params[:category_id])
      end
    end

    # Sort based on selection
    @products = case params[:sort]
    when "name_asc"
                  @products.order(:name)
    when "name_desc"
                  @products.order(name: :desc)
    when "price_asc"
                  @products.order(:price)
    when "price_desc"
                  @products.order(price: :desc)
    when "featured"
                  @products.order(featured: :desc, created_at: :desc)
    else
                  @products.order(created_at: :desc)
    end

    @products = @products.page(params[:page]).per(50)
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_products_path(session[:product_filters]), notice: "Product created successfully"
    else
      render :new
    end
  end

  def edit
    @product = Product.find(params[:id])
    # Store the current filters in session
    session[:product_filters] = {
      search: params[:search],
      category_id: params[:category_id],
      sort: params[:sort],
      page: params[:page],
      anchor: "product-#{@product.id}"
    }.compact
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to admin_products_path(session[:product_filters] || {}), notice: "Product updated successfully"
    else
      render :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to admin_products_path(session[:product_filters] || {}), notice: "Product deleted successfully"
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :price, :sale_price, :category_id, :featured, :image)
  end
end
