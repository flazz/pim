require 'sinatra'
require 'open-uri'
require 'cgi'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'pim'

module Pim

  # The Sinatra App
  class App < Sinatra::Default

    get '/' do
      redirect 'ajax'
    end
    
    get '/ajax' do
      @title = "PREMIS in METS Validator"
      erb :ajax_index
    end

    get '/plain' do
      @title = "PREMIS in METS Validator"
      erb :plain_index
    end

    # validation
    get '/validate' do
      halt 400, "query parameter document is required" unless params['document']
      @title = "Validation Results"
      url = CGI::unescape params['document']
      
      src = begin
              open(url) { |f| f.read }
            rescue => e
              halt 400, "cannot get url: #{url}, #{e.message}"
            end
      
      @results = Validation.new(src).results
      erb :validate
    end

    post '/validate' do
      halt 400, "query parameter idocument is required" unless params['document']
      @title = "Validation Results"
      
      src = case params['document']
            when Hash
              params['document'][:tempfile].read # XXX could be a ram hog
            when String
              params['document']
            end

      @results = Validation.new(src).results
      erb :validate
    end

    # convert premis to pim
    
  end

end

if __FILE__ == $0
  Pim::App.run!
end
