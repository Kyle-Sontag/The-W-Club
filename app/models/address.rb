class Address < ApplicationRecord
  belongs_to :user
  belongs_to :province

  validates :street, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true

  def full_address
    if province.present?
      "#{street}, #{city}, #{province.name} #{postal_code}"
    else
      "#{street}, #{city}, #{postal_code}"
    end
  end
end
