require 'scraper-base.rb'

class QatarSaleCarScraper < ScraperBase

  attr_reader :brand
  attr_accessor :form_params
  
  def initialize(page = 0)
    super('log/qatarsale.log', page)
    @brand = brand
    @site_id = 'qatarsalecars'
    @remoteBaseURL = 'http://qatarsale.com'
    @startURL = "/EnMain.aspx"
    @detailBaseURL = 'http://qatarsale.com/mycar_e.aspx?carid='
    @source = Source.find_by_name "Qatar Sale"
  end
  
  def get_total_properties(page)
    return 'Too many'
  end
  
  def get_start_page
    url = "#{@remoteBaseURL}#{@startURL}"
    retry_get url, MAX_TRIALS_EX
  end

  def get_next_page(page)
    begin
      form = page.at("//form[@id='form1']")
      if form
        params = {}
        (form/".//input").each do |input|
          params[input['name']] = input['value'] if input['value']
        end
        params['ScriptManager1'] = 'UpdatePanel4|GridView1'
        params['__EVENTTARGET'] = 'GridView1'
        params['__ASYNCPOST'] = 'true'
        params['__LASTFOCUS'] = ''
        params['expHF'] = ''
        params['CountryDropDown'] = "1"
        params['CarsDropDown'] = "0"
        params['ClassDropDown'] = "0"
        params['ModelDropDown'] = "0"
        params['CarYearDropDown'] = "0"
        params['CarPriceDropDown'] = "0"
        params['GearDD'] = "0"
        params['SellerDD'] = "0"
        params['YearTo'] = "0"
        params['YearFrom'] = "0"
        params['SeatsDD'] = "0"
        params['BodyColorDD'] = "0"
        params['KMTo'] = "0"
        params['KMFrom'] = "0"
        params['cylinderDD'] = "0"
        params['InsideColorDD'] = "0"
        params['PriceTo'] = "0"
        params['PriceFrom'] = "0"
        params['TypeDD'] = "0"
        params['WheelDD'] = "0"
        params['CPE1_ClientState'] = "true"

        self.form_params = params
      end

      self.form_params['__EVENTARGUMENT'] = "Page$#{@curr_page}"
      page = @agent.post "#{@remoteBaseURL}#{@startURL}", self.form_params
      page = Nokogiri::HTML(page.body)

    rescue
      nil
    end
  end

  def process_list_page(page)
    #puts page.uri.to_s
    
    new_items_found = false

    items = page/"//table[@id='GridView1']//table//tr/td/input[@type='image' and @title!='ShowRoom Map']"
    #puts "Found #{items.length} items in this page"

    @hercules.fight(items) do |image|
      v = Vehicle.new
      m = image['onclick'].match(/window.open\('(mycar_e\.aspx\?carid=[0-9]+)'/)
      v.url = "#{@remoteBaseURL}/#{m[1]}" if m
      v.source = @source
      v.sid_i = v.url.match(/carid=([0-9]+)/)[1]
      pline "  Item #{@curr_property} of #{@total}..."
      # get detailed info
      unless Vehicle.find_by_url(v.url)
        new_items_found = true
        process_detail_page(v) do |v|
          v.save
        end
      end
      @curr_property += 1
    end

    return new_items_found
  end

  def scrape
    super do
      max_id = Vehicle.order("sid_i desc").first

      @hercules.restart

      if max_id
        puts "Now scraping one by one in decreasing order starting from vehicle with id #{max_id.sid_i}"
        car_id = max_id.sid_i
        @hercules.fight(car_id.downto 0) do |car_id|
          v = Vehicle.new
          v.url = "#{@detailBaseURL}#{car_id}"
          v.source = @source
          v.sid_i = car_id
          pline "  Item #{@curr_property} of #{@total}..."
          # get detailed info
          unless Vehicle.find_by_sid_i(car_id)
            process_detail_page(v) do |v|
              v.save
            end
          else
            @logger.info "Vehicle is cached! #{v.url}"
          end
          @curr_property += 1
        end # @hercules.fight
      end # if max_id

      # TODO: THE FOLLOWING KILLED BLOCK NEVER GETS CALLED AND SCRIPT ENDS PREMATURELY (should daemonize not exit normally)
      @hercules.kill do |done_requests|
        pline "FINISHED #{done_requests} requests", true
        yield if block_given?
      end

    end # super yield
  end # scrape

  def get_string(page, name)
    v = node_text(page, "//span[@id='#{name}']")
    %w(N/A Undefined).include?(v) ? nil : v
  end

  def get_integer(page, name)
    v = get_string(page, name)
    v.to_i if v
  end

  def get_boolean(page, name)
    v = get_string(page, name)
    v == 'YES' if v
  end
  
  def get_time(page, name)
    v = get_string(page, name)
    v = v.to_time if v
  end
  
  def process_detail_page(vehicle)
    #page = retry_get vehicle.url
    @hercules.strike(vehicle.url) do |request, response_body|
      page = Nokogiri::HTML(response_body)
      #page.save_as("detailed.html")

      unless page.at("//div[@id='LOGOPANEL']")
        vehicle.title = node_text(page, "//head/title")
        vehicle.brand = Brand.where(name: get_string(page, 'd_carname')).first_or_create
        vehicle.model = get_integer(page, 'd_year')
        vehicle.class_name = get_string(page, 'd_classname')
        vehicle.trim_name = get_string(page, 'd_modelname')
        vehicle.outside_color = get_string(page, 'd_outcolor')
        vehicle.gear = get_string(page, 'd_gear')
        vehicle.cylinders = get_integer(page, 'd_cylinder')
        vehicle.vtype = get_string(page, 'd_DriveTrain')
        vehicle.inside_color = get_string(page, 'd_insidecolor')
        vehicle.inside_type = get_string(page, 'd_insidetype')
        vehicle.sunroof = get_boolean(page, 'd_slideroof')
        vehicle.sensors = get_boolean(page, 'd_Sensors')
        vehicle.camera = get_boolean(page, 'd_Camera')
        vehicle.dvd = get_boolean(page, 'd_dvd')
        vehicle.cd = get_boolean(page, 'd_cd')
        vehicle.bluetooth = get_boolean(page, 'd_Bluetooth')
        vehicle.gps = get_boolean(page, 'd_gps')
        vehicle.mileage = get_string(page, 'd_km')
        vehicle.price = get_string(page, 'd_price')
        vehicle.timestamp = get_time(page, 'ad_date')
        vehicle.contact_number = get_string(page, 'd_contact1')
        vehicle.contact_number2 = get_string(page, 'd_contact2')
        seller = page.at("//a[@id='d_seller2']") || page.at("//span[@id='d_seller4']")
        vehicle.username = seller.text.strip if seller
        yield vehicle
      else
        @logger.info "Vehicle with url #{vehicle.url} removed from website"
      end
    end
  end
  
end

