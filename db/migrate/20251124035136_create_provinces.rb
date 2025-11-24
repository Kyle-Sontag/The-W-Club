class CreateProvinces < ActiveRecord::Migration[8.0]
  def change
    create_table :provinces do |t|
      t.string :name
      t.decimal :gst_rate, precision: 5, scale: 2
      t.decimal :pst_rate, precision: 5, scale: 2
      t.decimal :hst_rate, precision: 5, scale: 2

      t.timestamps
    end
  end
end
