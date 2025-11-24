class User < ApplicationRecord
  has_many :addresses
  has_many :orders

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :encrypted_password, presence: true
end
