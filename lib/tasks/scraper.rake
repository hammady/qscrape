require "qatarliving-cars-scraper.rb"

def validate_brands(brands)
  if not brands.match(/^[\d ]+$/)
    puts "You should write brand ids (only numbers) separated by spaces"
    return false
  end
  return true
end

namespace :scraper do
  desc "Scrape items from QatarLiving by car make"
  task :scrape_brand, [:brands] => [:environment] do |t, args|
    brands = args.brands
    if brands == nil
      ScraperBase.read_file "#{RAILS_ROOT}/db/brands.txt" do |l|
        puts l
      end
      while brands == nil
        puts "No brand specified, please specify brand number then press ENTER: "
        brands = STDIN.gets
        brands = nil if not validate_brands(brands)
      end
    else
      exit if not validate_brands(brands)
    end

    brands.split.each do |brand_id|
      brand = Brand.find_by_id(brand_id)
      if brand != nil
        puts "Scraping brand with id: #{brand_id} (#{brand.name})"
        scraper = QatarLivingCarScraper.new brand
        scraper.scrape
      else
        puts "Could not find a brand with id: #{brand_id}"
      end
    end
  end

  desc "Scrape all items from QatarLiving"
  task :scrape, [:page] => [:environment] do |t, args|
    QatarLivingCarScraper.new(args[:page]).scrape
  end
end
