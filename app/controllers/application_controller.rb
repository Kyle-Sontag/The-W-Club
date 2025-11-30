class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_cart

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name ])
  end

  private

  def set_cart
    if user_signed_in?
      # Check if there's a guest cart in session
      if session[:cart_id]
        guest_cart = Cart.find_by(id: session[:cart_id], user_id: nil)

        if guest_cart
          # Merge guest cart into user's cart
          user_cart = current_user.cart || current_user.create_cart

          guest_cart.cart_items.each do |guest_item|
            existing_item = user_cart.cart_items.find_by(product_id: guest_item.product_id)

            if existing_item
              existing_item.quantity += guest_item.quantity
              existing_item.save
            else
              user_cart.cart_items.create(
                product: guest_item.product,
                quantity: guest_item.quantity
              )
            end
          end

          # Delete guest cart and clear session
          guest_cart.destroy
          session.delete(:cart_id)
        end
      end

      @current_cart = current_user.cart || current_user.create_cart
    else
      # For guest users, use session-based cart
      if session[:cart_id]
        @current_cart = Cart.find_by(id: session[:cart_id])
      end

      unless @current_cart
        @current_cart = Cart.create
        session[:cart_id] = @current_cart.id
      end
    end
  rescue ActiveRecord::RecordInvalid
    # If cart creation fails, create a new one
    @current_cart = Cart.create
    session[:cart_id] = @current_cart.id
  end
end
