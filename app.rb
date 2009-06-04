require 'sinatra'
require 'open-uri'
require 'cgi'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'validation'
require 'xslt'

XML::Error.set_handler(&XML::Error::QUIET_HANDLER)

module Pim

  # The Sinatra App
  class App < Sinatra::Default

    # index
    get '/' do
      erb :index
    end

    # validate PiM
    get '/validate' do
      @title = "PREMIS in METS Validator"
      erb :'validate/index'
    end

    get '/validate/results' do
      halt 400, "query parameter document is required" unless params['document']
      @title = "Validation Results"
      url = CGI::unescape params['document']

      src = begin
              open(url) { |f| f.read }
            rescue => e
              halt 400, "cannot get url: #{url}, #{e.message}"
            end

      @results = Validation.new(src).results
      erb :'validate/results'
    end

    post '/validate/results' do
      halt 400, "query parameter document is required" unless params['document']
      @title = "Validation Results"

      src = case params['document']
            when Hash
              params['document'][:tempfile].read # XXX could be a ram hog
            when String
              params['document']
            end

      @results = Validation.new(src).results
      erb :'validate/results'
    end

    # convert PREMIS to PiM
    get '/convert' do
      @title = "PREMIS in METS Converter"
      @convert = 'p2pim'
      erb :'convert/index'
    end

    get '/convert/results' do
      halt 400, "query parameter document is required" unless params['document']
      halt 400, "query parameter convert is required" unless params['convert']
      content_type 'application/xml', :charset => 'utf-8'
      @title = "Conversion Results"
      url = CGI::unescape params['document']

      src = begin
              open(url) { |f| f.read }
            rescue => e
              halt 400, "cannot get url: #{url}, #{e.message}"
            end
      
      doc = XML::Parser.string(src).parse
      
      case params['convert']
      when 'p2pim'
        if params['embed_as'] == "buckets"
          PREMIS_TO_PIM_BUCKETS_XSLT.apply(doc).to_s
        else
          PREMIS_TO_PIM_CONTAINER_XSLT.apply(doc).to_s
        end
      when 'pim2p'
        halt 501, "Under Construction"
      else
        halt 400, 'parameter convert must be "p2pim" or "pim2p"'
      end

    end

    post '/convert/results' do
      halt 400, "query parameter document is required" unless params['document']
      halt 400, "query parameter convert is required" unless params['convert']
      content_type 'application/xml', :charset => 'utf-8'
      @title = "Conversion Results"

      src = case params['document']
            when Hash
              params['document'][:tempfile].read # XXX could be a ram hog
            when String
              params['document']
            end

      doc = XML::Parser.string(src).parse

      case params['convert']
      when 'p2pim'
        if params['embed_as'] == "buckets"
          PREMIS_TO_PIM_BUCKETS_XSLT.apply(doc).to_s
        else
          PREMIS_TO_PIM_CONTAINER_XSLT.apply(doc).to_s
        end
      when 'pim2p'
        halt 501, "Under Construction"
      else
        halt 400, 'parameter convert must be "p2pim" or "pim2p"'
      end

    end

  end

end

if __FILE__ == $0
  Pim::App.run!
end
