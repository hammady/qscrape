#require 'db.rb'
#require 'vehicle.rb'
#require 'actionmailer'

namespace :scraper do
  desc "Notify recipients about new items scraped from QatarLiving"
  task :notify, [:criteria] => [:environment] do |t, args|

    # configure actionmailer
    #ActionMailer::Base.template_root = "#{RAILS_ROOT}/app/views"
    #email_settings = YAML::load(File.open("#{RAILS_ROOT}/config/email.yml"))
    #ActionMailer::Base.smtp_settings = email_settings[RAILS_ENV] unless email_settings[RAILS_ENV].nil?
    ActionMailer::Base.smtp_settings = {
      :address => "smtp.gmail.com",
      :port => 587,
      :enable_starttls_auto => true,
      :authentication => :plain,
      :user_name => "notifier@hammady.net",
      :password => "T68858"
    }

    if args.criteria == nil
      puts "You should specify any search keywords to avoid huge result sets"
      exit
    end

    arr = []
    args.criteria.split.each do |arg|
      arr << "concat(title, ' ', description) like '%#{arg}%'"
    end

    results = Vehicle.find(:all, :conditions => "(#{arr.join(" or ")}) and notified_at is null")
    puts "#{results.length} result(s) found"

    RETRIALS = 3
    results.each do |vehicle|
      puts "Sending mail for vehicle [#{vehicle.id}] #{vehicle.title}..."
      attempts = 0
      success = false
      while not success and attempts < RETRIALS
          Notifier.deliver_new_car_notification vehicle
        begin
          vehicle.notified_at = Time.now
          vehicle.save
          success = true
        rescue
          puts "Failed sending email, retrying..."
          attempts = attempts + 1
        end
      end
    end
  end
end
