class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :addresses
  has_many :orders

  validates :first_name, presence: true
  validates :last_name, presence: true

  def admin?
    admin
  end
end
