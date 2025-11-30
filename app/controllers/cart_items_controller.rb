class CartItemsController < ApplicationController
  def create
    product = Product.find(params[:product_id])
    @cart_item = @current_cart.cart_items.find_by(product_id: product.id)

    if @cart_item
      @cart_item.quantity += 1
      @cart_item.save
    else
      @cart_item = @current_cart.cart_items.create(product: product, quantity: 1)
    end

    # Store the referring page in session
    session[:return_to] = request.referer

    redirect_to cart_path, notice: "#{product.name} added to cart"
  end

  def update
    @cart_item = @current_cart.cart_items.find(params[:id])
    @cart_item.update(quantity: params[:quantity])
    redirect_to cart_path
  end

  def destroy
    @cart_item = @current_cart.cart_items.find(params[:id])
    @cart_item.destroy
    redirect_to cart_path, notice: "Item removed from cart"
  end
end
