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
      @current_cart = current_user.cart || Cart.create(user: current_user)
    else
      # For guest users, use session-based cart
      session[:cart_id] ||= Cart.create.id
      @current_cart = Cart.find_by(id: session[:cart_id])
      @current_cart ||= Cart.create.tap { |cart| session[:cart_id] = cart.id }
    end
  end
end
