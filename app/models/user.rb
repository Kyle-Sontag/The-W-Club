class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :addresses
  has_many :orders
  has_one :cart, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true

  # Ensure user always has a cart
  after_create :create_user_cart

  def admin?
    admin
  end

  def create_user_cart
    Cart.create(user: self) unless cart.present?
  end
end
