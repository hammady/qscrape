require 'scraper-base.rb'

class QatarLivingCarScraper < ScraperBase

  
  def initialize(page = 0)
    super('log/qatarliving.log', page)
	  @site_id = 'qatarlivingcars'
		@remoteBaseURL = 'http://www.qatarliving.com'
		@startURL = "/classifieds/search?f%5B0%5D=im_cl_category%3A100556&page=#{page}"
		@detailBaseURL = 'http://www.qatarliving.com/vehicles'
    @source = Source.find_by_name "Qatar Living"
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

  def get_start_page
    url = "#{@remoteBaseURL}#{@startURL}"
    retry_get url, MAX_TRIALS_EX
  end
  
  def get_next_page(page)
    begin
      anchor = page.at("//ul[@class='pager']/li[@class='pager-next']/a")
      url = "#{@remoteBaseURL}#{anchor['href']}"
      retry_get(url, MAX_TRIALS_EX)
    rescue
      nil
    end
  end

  def process_list_page(page)
    #puts page.uri.to_s
    
    new_items_found = false
    
    items = page/"//div[@class='view-content']/div[@class='item-list']/ol/li"
    @hercules.fight(items) do |li|
      v = Vehicle.new
      anchor = li.at(".//h3[@class='title']/a")
      if anchor
        v.title = anchor.text
        pline "  Item #{@curr_property} of #{@total}..."
        # get detailed info
        href = anchor['href']
        v.url = "#{@remoteBaseURL}#{href}"
        #puts "processing: #{anchor.text} [#{href}]"
        arr = node_text(li, ".//h4[@class='title']").split(/\s*in\s*/)
        v.vtype = arr[0]
        v.location = arr[1]
        unless Vehicle.find_by_url(v.url)
          new_items_found = true
          process_detail_page(v) do |v|
            v.source = @source
            v.save
          end
        end
      end
      @curr_property = @curr_property + 1
    end
    return new_items_found
  end
  
	def process_detail_page(vehicle)
    #page = retry_get vehicle.url
    @hercules.strike(vehicle.url) do |request, response_body|
      page = Nokogiri::HTML(response_body)
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
          vehicle.brand_name = val
        when "vehicle mileage"
          vehicle.mileage = val
        end
      end
      
      # description
      vehicle.description = node_html(page, ".//div[@class='field field-name-body field-type-text-with-summary field-label-hidden field-item even']")

      # images
      (page/"//figure[@class='field field-group-field-image']//a").each do |anchor|
        vehicle.images.build url: anchor['href']
      end

      yield vehicle
    end
	end
  
end

