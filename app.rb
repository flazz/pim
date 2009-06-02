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
      halt 400, "query parameter document is required" unless params['document']
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
    get '/premis2pim' do
      redirect '/premis2pim/ajax'
    end

    # Index display
    get '/premis2pim/:type' do

      @title = "PREMIS-in-METS Converter"
      @heading = "PREMIS to PREMIS-in-METS Conversion Service"
      @convert = "p2pim"

      template =  case params['type']
                    when 'plain' then "plain_convert"
                    when 'ajax' then "ajax_convert"
                    else status 404
                  end

      erb :"#{template}"

    end
    
    get '/convert' do
      halt 400, "query parameter document is required" unless params['document']
      halt 400, "query parameter convert is required" unless params['convert']
      
      @title = "Conversion Results"
      
      @results = case params['convert']
                   when 'p2pim'
                     Pim.generate_pim params['document'], params['embed_as']
                   when 'pim2p'
                     "Under Construction"
                   else
                     halt 400, 'parameter convert must be "p2pim" or "pim2p"'
                 end
      
      erb :conversion_results
 
    end
    
    post '/convert' do
      halt 400, "query parameter document is required" unless params['document']
      halt 400, "query parameter convert is required" unless params['convert']
      
      @title = "Conversion Results"
      
      src = case params['document']
            when Hash
              params['document'][:tempfile].read # XXX could be a ram hog
            when String
              params['document']
            end
      
      @results = case params['convert']
                   when 'p2pim'
                     Pim.generate_pim src, params['embed_as']
                   when 'pim2p'
                     "Under Construction"
                   else
                     halt 400, 'parameter convert must be "p2pim" or "pim2p"'
                 end
      erb :conversion_results
    end



    # can this be factored out?
  end

end

if __FILE__ == $0
  Pim::App.run!
end
