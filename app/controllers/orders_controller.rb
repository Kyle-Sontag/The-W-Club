class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  def new
    @order = Order.new
    @addresses = current_user.addresses
    @cart = @current_cart

    if @cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty"
    end
  end

  def create
    @address = current_user.addresses.find(params[:address_id])
    province = @address.province

    # Calculate totals
    subtotal = @current_cart.subtotal
    taxes = @current_cart.calculate_taxes(province)
    total = @current_cart.total_with_tax(province)

    # Create order
    @order = current_user.orders.new(
      address: @address,
      subtotal: subtotal,
      gst: taxes[:gst],
      pst: taxes[:pst],
      hst: taxes[:hst],
      total: total,
      status: :pending
    )

    if @order.save
      # Create order items from cart items
      @current_cart.cart_items.each do |cart_item|
        @order.order_items.create(
          product: cart_item.product,
          quantity: cart_item.quantity,
          price: cart_item.product.current_price
        )
      end

      # Clear cart
      @current_cart.cart_items.destroy_all

      redirect_to order_path(@order), notice: "Order placed successfully!"
    else
      @addresses = current_user.addresses
      @cart = @current_cart
      render :new
    end
  end
end
