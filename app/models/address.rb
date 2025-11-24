class Address < ApplicationRecord
  belongs_to :user
  belongs_to :province

  validates :street, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true, format: { with: /\A[A-Z]\d[A-Z] ?\d[A-Z]\d\z/i }
end
