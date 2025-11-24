require 'csv'

puts "Clearing existing data..."
Product.destroy_all
Category.destroy_all

puts "Creating categories..."
categories = {
  jerseys: Category.create!(name: "Jerseys", description: "Official Winnipeg Blue Bombers jerseys for all ages"),
  mens: Category.create!(name: "Mens", description: "Men's Blue Bombers apparel and clothing"),
  womens: Category.create!(name: "Womens", description: "Women's Blue Bombers apparel and clothing"),
  headwear: Category.create!(name: "Headwear", description: "Hats, toques, and caps"),
  accessories: Category.create!(name: "Accessories", description: "Flags, pins, decals, and other Blue Bombers accessories"),
  sale: Category.create!(name: "Sale", description: "Discounted Blue Bombers merchandise")
}

puts "Importing products..."

csv_files = {
  'jerseys.csv' => categories[:jerseys],
  'mens.csv' => categories[:mens],
  'womens.csv' => categories[:womens],
  'headwear.csv' => categories[:headwear],
  'accessories.csv' => categories[:accessories],
  'sale.csv' => categories[:sale]
}

csv_files.each do |filename, category|
  csv_path = Rails.root.join('db', 'data', filename)

  CSV.foreach(csv_path, headers: true) do |row|
    next if row['title'].blank?

    price = row['new-price']&.gsub('C$', '')&.strip&.to_f
    next if price.nil? || price <= 0

    Product.create!(
      category: category,
      name: row['title'],
      description: row['description'].presence || "Official Winnipeg Blue Bombers merchandise",
      price: price,
      sale_price: (filename == 'sale.csv' ? price : nil),
      image_url: row['first src']
    )
  end
end

puts "\nComplete!"
puts "Categories: #{Category.count}"
puts "Products: #{Product.count}"
Category.all.each { |c| puts "  #{c.name}: #{c.products.count}" }
