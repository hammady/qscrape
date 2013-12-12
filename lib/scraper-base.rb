require 'mechanize'
require 'logger'

class ScraperBase

  MAX_TRIALS = 3
  MAX_TRIALS_EX = 50

	def initialize(log_file = 'scraper.log', page = 0)
	  @site_id = 'UNKNOWN'
		@agent = Mechanize.new
		@agent.user_agent_alias = 'Linux Mozilla' #'Windows IE 6'
		# disable history to prevent infinitely growing memory!
		@agent.history.max_size=0
		@logger = Logger.new(log_file, 'daily') 
		@logger.level = Logger::DEBUG
    @page = page.to_i
	end
	
	def saveResultsToFile(fileName)
		f = File.new(fileName, 'w')
		f.write(@results.content)
		f.close
	end

	def ScraperBase.read_file(fileName)
		f = File.new(fileName, 'r')
		c = f.read()
		f.close()
		c.each_line do |l|
		  yield l.chomp!
		end
	end

  def pline(line, newline=false)
    print "\r#{line}"
    print (" " * 10)
    print "\n" if newline
    $stdout.flush
  end
  
	def scrape
    url = "#{@remoteBaseURL}#{@startURL}&page=#{@page}"
	  page = retry_get url, MAX_TRIALS_EX
	  #page.save_as "1.html"

    iterate_list_pages(page)

    pline "FINISHED", true
		@logger.close
	end
	
  def iterate_list_pages(page)
    @total, @per_page = get_total_properties(page)
    puts "total items: #{@total}"
    @curr_property = (@page || 0) * (@per_page || 0) + 1
    curr_page = (@page || 0) + 1
    while page != nil
      pline "Processing page #{curr_page}...", true
      new_items_found = process_list_page(page)
      if new_items_found
        #page.save_as("list#{curr_page}.html")
        curr_page = curr_page + 1
        url = get_next_page_link(page)
        page = nil
        page = retry_get(url, MAX_TRIALS_EX) if url
      else
        puts "No new items found on this page, skipping to the end"
        page = nil
      end
    end
  end
  
  def node_text(page, xpath)
    n = page.at(xpath)
    n = n.text.strip if n
  end
  
  def node_html(page, xpath)
    n = page.at(xpath)
    n = n.inner_html.strip if n
  end

  def retry_get(url, trials = MAX_TRIALS, sleep_for = 1)
    begin
      #sleep 1 # be calm and don't hit the server aggresively
      @agent.get url
    rescue => e
      trials -= 1
      if trials > 0
        @logger.warn "Ops, server returned error, sleeping #{sleep_for} second(s) then retrying (#{trials} trial(s) remaining)..."
        sleep sleep_for
        retry_get url, trials, sleep_for + 1
      else # give up
        @logger.warn "Giving up after consuming maximum trials"
        raise e
      end
    end
  end
end
