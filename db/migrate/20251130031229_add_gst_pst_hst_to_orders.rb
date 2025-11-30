class AddGstPstHstToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :gst, :decimal, precision: 10, scale: 2, default: 0
    add_column :orders, :pst, :decimal, precision: 10, scale: 2, default: 0
    add_column :orders, :hst, :decimal, precision: 10, scale: 2, default: 0
  end
end
