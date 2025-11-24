class Product < ApplicationRecord
  belongs_to :category

  validates :name, presence: true
  validates :description, presence: true, allow_blank: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true
end
