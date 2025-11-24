class Order < ApplicationRecord
  belongs_to :user
  belongs_to :address
  has_many :order_items
  has_many :products, through: :order_items

  validates :status, presence: true
  validates :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :tax, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
