class Notifier < ActionMailer::Base
 def new_car_notification(vehicle)
   recipients "hammady@gmail.com,nehal.gaballah@gmail.com"
   from       "notifier@hammady.net"
   subject    "QatarLiving: #{vehicle.title}"
   body       :vehicle => vehicle
 end
end

