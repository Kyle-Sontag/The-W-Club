require 'csv'
require 'open-uri'

puts "Clearing existing data..."
Product.destroy_all
Category.destroy_all

# Seed provinces with real Canadian tax rates
puts "Creating provinces..."
Province.destroy_all

provinces_data = [
  { name: "Alberta", gst_rate: 5.0, pst_rate: 0.0, hst_rate: 0.0 },
  { name: "British Columbia", gst_rate: 5.0, pst_rate: 7.0, hst_rate: 0.0 },
  { name: "Manitoba", gst_rate: 5.0, pst_rate: 7.0, hst_rate: 0.0 },
  { name: "New Brunswick", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 15.0 },
  { name: "Newfoundland and Labrador", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 15.0 },
  { name: "Northwest Territories", gst_rate: 5.0, pst_rate: 0.0, hst_rate: 0.0 },
  { name: "Nova Scotia", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 15.0 },
  { name: "Nunavut", gst_rate: 5.0, pst_rate: 0.0, hst_rate: 0.0 },
  { name: "Ontario", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 13.0 },
  { name: "Prince Edward Island", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 15.0 },
  { name: "Quebec", gst_rate: 5.0, pst_rate: 9.975, hst_rate: 0.0 },
  { name: "Saskatchewan", gst_rate: 5.0, pst_rate: 6.0, hst_rate: 0.0 },
  { name: "Yukon", gst_rate: 5.0, pst_rate: 0.0, hst_rate: 0.0 }
]

provinces_data.each do |data|
  Province.create!(data)
end

puts "Created #{Province.count} provinces"

puts "Creating categories..."
categories = {
  jerseys: Category.create!(name: "Jerseys", description: "Official Winnipeg Blue Bombers jerseys for all ages"),
  mens: Category.create!(name: "Mens", description: "Men's Blue Bombers apparel and clothing"),
  womens: Category.create!(name: "Womens", description: "Women's Blue Bombers apparel and clothing"),
  headwear: Category.create!(name: "Headwear", description: "Hats, toques, and caps"),
  accessories: Category.create!(name: "Accessories", description: "Flags, pins, decals, and other Blue Bombers accessories")
}

puts "Importing products..."

# Track products by name to avoid duplicates and identify sale items
products_by_name = {}

# First pass: Import all non-sale products
csv_files = {
  'jerseys.csv' => categories[:jerseys],
  'mens.csv' => categories[:mens],
  'womens.csv' => categories[:womens],
  'headwear.csv' => categories[:headwear],
  'accessories.csv' => categories[:accessories]
}

csv_files.each do |filename, category|
  csv_path = Rails.root.join('db', 'data', filename)

  CSV.foreach(csv_path, headers: true) do |row|
    next if row['title'].blank?

    price = row['new-price']&.gsub('C$', '')&.strip&.to_f
    next if price.nil? || price <= 0

    product = Product.create!(
      category: category,
      name: row['title'],
      description: row['description'].presence || "Official Winnipeg Blue Bombers merchandise",
      price: price,
      sale_price: nil,
      image_url: row['first src']
    )

    # Track by name for sale processing
    products_by_name[row['title']] = product

    # Attach image from URL if available
    image_url = row['first src']
    if image_url.present?
      begin
        file = URI.open(image_url)
        product.image.attach(io: file, filename: "#{product.id}.jpg")
      rescue => e
        puts "   Could not download image for #{product.name}"
      end
    end
  end
end

# Second pass: Process sale items by updating existing products with sale_price
puts "Processing sale items..."
sale_csv_path = Rails.root.join('db', 'data', 'sale.csv')

CSV.foreach(sale_csv_path, headers: true) do |row|
  next if row['title'].blank?

  product_name = row['title']
  original_price = row['old-price']&.gsub('C$', '')&.strip&.to_f
  sale_price = row['new-price']&.gsub('C$', '')&.strip&.to_f

  next if sale_price.nil? || sale_price <= 0

  # Find the product by name and update it with sale price
  if products_by_name[product_name]
    product = products_by_name[product_name]
    product.update!(
      price: original_price || product.price,
      sale_price: sale_price
    )
    puts "  Updated #{product_name} with sale price"
  else
    puts "  Sale item '#{product_name}' not found in regular products"
  end
end

puts "\nComplete!"
puts "Categories: #{Category.count}"
puts "Products: #{Product.count}"
Category.all.each { |c| puts "  #{c.name}: #{c.products.count}" }
puts "Products on sale: #{Product.where.not(sale_price: nil).count}"
