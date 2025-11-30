class Order < ApplicationRecord
  belongs_to :user
  belongs_to :address
  has_many :order_items, dependent: :destroy

  validates :status, presence: true
  validates :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :gst, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :pst, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :hst, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total, presence: true, numericality: { greater_than: 0 }

  enum :status, { pending: 0, paid: 1, shipped: 2 }

  def total_tax
    gst + pst + hst
  end
end
