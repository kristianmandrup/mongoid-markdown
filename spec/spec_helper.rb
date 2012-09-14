require 'rspec'
require 'moped'
require 'mongoid'

require 'mongoid-markdown'

Mongoid.configure do |config|
  config.connect_to('mongoid_markdown-test')
end

RSpec.configure do |config|  
  config.before(:each) do
    Mongoid.purge!
  end
end
