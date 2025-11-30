class OrdersController < ApplicationController
  before_action :authenticate_user!, except: []

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  def checkout
    @cart = @current_cart
    @addresses = current_user.addresses

    if @cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty"
      return
    end

    # Build a new address if user has none
    @address = current_user.addresses.build if @addresses.empty?
  end

  def review
    # Parse billing selection
    billing_selection = params[:billing_selection]

    if billing_selection.blank?
      redirect_to checkout_orders_path, alert: "Please select a billing address"
      return
    end

    if billing_selection == "new"
      # Create new billing address (not saved yet)
      if params[:billing_address][:street].blank? || params[:billing_address][:province_id].blank?
        redirect_to checkout_orders_path, alert: "Please fill out the billing address fields"
        return
      end

      @billing_address = Address.new(params[:billing_address].permit(:street, :city, :province_id, :postal_code))
      @billing_address.province = Province.find(params[:billing_address][:province_id])
      session[:new_billing_address] = params[:billing_address].permit(:street, :city, :province_id, :postal_code).to_h
      session[:billing_selection] = "new"
    else
      # Extract ID from "existing_123" format
      address_id = billing_selection.split("_").last.to_i
      @billing_address = current_user.addresses.find(address_id)
      session[:billing_selection] = billing_selection
    end

    # Parse shipping selection
    shipping_selection = params[:shipping_selection]

    if shipping_selection.blank?
      redirect_to checkout_orders_path, alert: "Please select a shipping option"
      return
    end

    if shipping_selection == "same"
      @shipping_address = @billing_address
      session[:shipping_selection] = "same"
    elsif shipping_selection == "new"
      if params[:shipping_address][:street].blank? || params[:shipping_address][:province_id].blank?
        redirect_to checkout_orders_path, alert: "Please fill out the shipping address fields"
        return
      end

      @shipping_address = Address.new(params[:shipping_address].permit(:street, :city, :province_id, :postal_code))
      @shipping_address.province = Province.find(params[:shipping_address][:province_id])
      session[:new_shipping_address] = params[:shipping_address].permit(:street, :city, :province_id, :postal_code).to_h
      session[:shipping_selection] = "new"
    else
      address_id = shipping_selection.split("_").last.to_i
      @shipping_address = current_user.addresses.find(address_id)
      session[:shipping_selection] = shipping_selection
    end

    @cart = @current_cart
    @province = @shipping_address.province
    @taxes = @cart.calculate_taxes(@province)
    @total = @cart.total_with_tax(@province)

    puts "About to render review..."
    render :review
  rescue => e
    puts "ERROR: #{e.message}"
    puts e.backtrace.first(10)
    redirect_to checkout_orders_path, alert: "Error processing checkout: #{e.message}"
  end

  def place_order
    # Handle billing address
    billing_selection = session[:billing_selection]

    if billing_selection == "new"
      billing_address = current_user.addresses.create!(session[:new_billing_address])
    else
      address_id = billing_selection.split("_").last.to_i
      billing_address = current_user.addresses.find(address_id)
    end

    # Handle shipping address
    shipping_selection = session[:shipping_selection]

    if shipping_selection == "same"
      shipping_address = billing_address
    elsif shipping_selection == "new"
      shipping_address = current_user.addresses.create!(session[:new_shipping_address])
    else
      address_id = shipping_selection.split("_").last.to_i
      shipping_address = current_user.addresses.find(address_id)
    end

    # Calculate totals
    province = shipping_address.province
    subtotal = @current_cart.subtotal
    taxes = @current_cart.calculate_taxes(province)
    total = @current_cart.total_with_tax(province)

    # Create order
    @order = current_user.orders.create!(
      address: shipping_address,
      subtotal: subtotal,
      gst: taxes[:gst],
      pst: taxes[:pst],
      hst: taxes[:hst],
      total: total,
      status: :pending
    )

    # Create order items
    @current_cart.cart_items.each do |cart_item|
      @order.order_items.create!(
        product: cart_item.product,
        quantity: cart_item.quantity,
        price_at_purchase: cart_item.product.current_price
      )
    end

    # Clear cart and session
    @current_cart.cart_items.destroy_all

    session.delete(:billing_selection)
    session.delete(:shipping_selection)
    session.delete(:new_billing_address)
    session.delete(:new_shipping_address)

    redirect_to order_path(@order), notice: "Order placed successfully!"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to checkout_orders_path, alert: "Error creating order: #{e.message}"
  end

  private

  def billing_address_params
    params.require(:billing_address).permit(:street, :city, :province_id, :postal_code)
  end

  def shipping_address_params
    params.require(:shipping_address).permit(:street, :city, :province_id, :postal_code)
  end
end
