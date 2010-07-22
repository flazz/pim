require 'rubygems'
require 'bundler'
Bundler.setup

require 'app'

set :env, :production

run Sinatra::Application
