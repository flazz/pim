require 'rubygems'
gem 'sinatra', '~> 0.9'

# add the load path
require 'app'

set :run, false
set :environment, :production
run Pim
