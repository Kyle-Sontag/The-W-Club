class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def add_product(product, quantity = 1)
    current_item = cart_items.find_by(product_id: product.id)

    if current_item
      current_item.quantity += quantity
      current_item.save
    else
      cart_items.create(product: product, quantity: quantity)
    end
  end

  def subtotal
    cart_items.sum { |item| item.quantity * item.product.current_price }
  end

  def calculate_taxes(province)
    gst = subtotal * (province.gst_rate / 100)
    pst = subtotal * (province.pst_rate / 100)
    hst = subtotal * (province.hst_rate / 100)

    {
      gst: gst,
      pst: pst,
      hst: hst,
      total_tax: gst + pst + hst
    }
  end

  def total_with_tax(province)
    taxes = calculate_taxes(province)
    subtotal + taxes[:total_tax]
  end

  def total_price
    subtotal
  end

  def total_items
    cart_items.sum(:quantity)
  end
end
