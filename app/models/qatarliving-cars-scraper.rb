require 'scraper-base.rb'
require 'vehicle.rb'

class QatarLivingCarScraper < ScraperBase

  attr_reader :brand
  
  def initialize(page = 0)
    super('log/qatarliving.log', page)
    @brand = brand
	  @site_id = 'qatarlivingcars'
		@remoteBaseURL = 'http://www.qatarliving.com'
		@startURL = "/classifieds/search?f%5B0%5D=im_cl_category%3A100556"
		@detailBaseURL = 'http://www.qatarliving.com/vehicles'
	end
	
  def get_total_properties(page)
	  begin
      per_page = (page/("//div[@class='view-content']/div[@class='item-list']/ol/li")).length
      anchor = page.at("//ul[@class='pager']/li[@class='pager-last last']/a")
      matches = anchor['href'].match(/page=([0-9]+)/)
      return (matches[1].to_i + 1) * per_page, per_page
    rescue
  	  return 'Unknown', nil
    end
  end
  
  def get_next_page_link(page)
    begin
      anchor = page.at("//ul[@class='pager']/li[@class='pager-next']/a")
      return "#{@remoteBaseURL}#{anchor['href']}"
    rescue
      nil
    end
    nil
  end

  def process_list_page(page)
    #puts page.uri.to_s
    
    new_items_found = false
    
    (page/"//div[@class='view-content']/div[@class='item-list']/ol/li").each do |li|
      v = Vehicle.new
      anchor = li.at(".//h3[@class='title']/a")
      v.title = anchor.text
      pline "  Item #{@curr_property} of #{@total}..."
      # get detailed info
      href = anchor['href']
      v.url = "#{@remoteBaseURL}#{href}"
      #puts "processing: #{anchor.text} [#{href}]"
      arr = node_text(li, ".//h4[@class='title']").split(/\s*in\s*/)
      v.vtype = arr[0]
      v.location = arr[1]
      begin
        unless Vehicle.find_by_url(v.url)
          new_items_found = true
          v = process_detail_page(v)
          v.save
        end
      rescue => exception
        @logger.error "Exception thrown while processing #{v.url}"
        @logger.error exception
        @logger.error exception.backtrace.join("\n")
      end
      @curr_property = @curr_property + 1
    end
    return new_items_found
  end
  
	def process_detail_page(vehicle)
    page = retry_get vehicle.url

	  #page.save_as("detailed.html")

    # datetime
    datetime = page.at("//p[@class='byline']/time")['datetime']
    vehicle.timestamp = datetime.to_time if datetime

    # username
    anchor = page.at("//p[@class='byline']/a[@class='username']")
    m = anchor['href'].match(/\/user\/(.+)/) if anchor
    vehicle.username = m[1] if m

    # contact info
    anchor = page.at("//ul[@class='action-links']//a[@class='phone']")
    m = anchor['href'].match(/tel:(.+)/) if anchor
    vehicle.contact_number = m[1] if m

    # price
    m = node_text(page, "//div[@id='content']/h2[@class='title']").match(/([0-9]+)\s+QAR/)
    vehicle.price = m[1] if m

    # model, make, mileage
    (page/"//div[@class='item-list']").each do |node|
      key = node_text(node, ".//h3")
      val = node_text(node, ".//ul")
      #puts "#{key} = #{val}"
      case key.downcase
      when "year model"
        vehicle.model = val
      when "vehicle make"
        vehicle.brand = Brand.where(name: val).first_or_create
      when "vehicle mileage"
        vehicle.mileage = val
      end
    end
    
    # description
    vehicle.description = node_html(page, ".//div[@class='field field-name-body field-type-text-with-summary field-label-hidden field-item even']")

    vehicle
	end
  
end

