class ApplicationController < ActionController::Base
  private

  def authenticate_admin!
    authenticate_or_request_with_http_basic("Admin Area") do |username, password|
      username == "admin" && password == "password123"
    end
  end
end
