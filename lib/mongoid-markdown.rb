require 'rdiscount'

if Mongoid::VERSION < '2.4.0' 
  require 'mongoid-markdown/mongoid_old'
else
  require 'mongoid-markdown/mongoid_new'
end