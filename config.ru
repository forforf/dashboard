
module Dashboard
  ROOT = File.dirname(__FILE__)
end

require Dashboard::ROOT + '/config/boot.rb'


#run Rack::URLMap.new({
#  "/dashboard"    => Dashboard::Server
#   "/bar" => Foobar::Bar
#})
