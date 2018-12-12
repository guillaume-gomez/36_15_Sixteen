require './api'
require './auth'
run Rack::Cascade.new [CallSixteen, Auth]
