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

    helpers do

      # common interface to the input forms
      def input_form type, options={}
        view = "forms/#{type.id2name}".intern
        erb view, :layout => false, :locals => options
      end
      
      # Common handler for conversion results
      def handle_conversion src
        
        # validate incoming src, for now 400 if bad
        v = Validation.new(src).validity
        halt 400, "Validation errors exist" unless v.compact.empty?
        
        @title = "Conversion Results"
        doc = XML::Parser.string(src).parse
        
        case doc.root.namespaces.namespace.to_s
        when 'info:lc/xmlns/premis-v2'
          xform = if params['use-premis-container'] == "on"
                    PREMIS_TO_PIM_CONTAINER_XSLT
                  else
                    PREMIS_TO_PIM_BUCKETS_XSLT
                  end

          content_type 'application/xml', :charset => 'utf-8'
          xform.apply(doc).to_s
        when 'http://www.loc.gov/METS/'
          content_type 'application/xml', :charset => 'utf-8'
          PIM_TO_PREMIS_XSLT.apply(doc).to_s
        else
          halt 400, 'document must either be premis or mets'
        end
      end

    end

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
      erb :'convert/index'
    end

    get '/convert/results' do
      halt 400, "query parameter document is required" unless params['document']
      url = params['document']

      src = begin
              open(url) { |f| f.read }
            rescue => e
              halt 400, "cannot get url: #{url}, #{e.message}"
            end

      handle_conversion src
    end

    post '/convert/results' do
      halt 400, "query parameter document is required" unless params['document']
      
      src = case params['document']
            when Hash
              params['document'][:tempfile].read # XXX could be a ram hog
            when String
              params['document']
            end

      handle_conversion src
    end

  end

end

if __FILE__ == $0
  Pim::App.run!
end
