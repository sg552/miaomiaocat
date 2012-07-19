require 'tire/search.rb'

Tire.configure do
  logger Settings.tire.logger
  url Settings.tire.url
end

