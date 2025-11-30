class Address < ApplicationRecord
  belongs_to :user
  belongs_to :province

  validates :street, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true

  def full_address
    "#{street}, #{city}, #{province.name} #{postal_code}"
  end
end
