class AddFeaturedToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :featured, :boolean, default: false
  end
end
