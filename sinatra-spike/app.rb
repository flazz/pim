require 'sinatra'
require 'open-uri'
require 'libxml'
require 'cgi'
require 'schematron'

mime :xml, 'application/xml'
mime :json, 'application/json'

include LibXML

get '/' do
  @title = "PiM"
  erb :index
end

get '/validate' do
  raw_url = params['document']
  halt 400, "query parameter document is required" if raw_url.nil?

  url = CGI::unescape raw_url
  
  @results = open(url) do |f|
    validate f
  end

  erb :validate_html
end

post '/validate' do
  raw = params['document'][:tempfile]
  halt 400, "POST variable document is required" if raw.nil?
  
  @results = validate raw
  erb :validate_html
end

def validate(raw_io)

  # TODO catch errors for well formedness
  instance_parser = XML::Parser.io raw_io
  instance_doc = instance_parser.parse

  # TODO validate the xml against the xml schema
  
  # validate against schematron PiM
  # TODO factor this to app load time once
  stron_parser = XML::Parser.file File.join(File.dirname(__FILE__), "schema", "pim.stron")
  stron_doc = stron_parser.parse

  XML.default_line_numbers = true
  stron = Schematron::Schema.new stron_doc

  stron.validate instance_doc
end

# call this when we support multiple formats
def render_requested_format
  
  compatible = request.accept.select do |mt|
    [ "text/html",
      "application/xml",
      "application/json" ].include? mt
  end
  
  case compatible.first
  when "text/html"
    erb :validate_html
  when "application/xml"
    content_type :xml
    erb :validate_xml
  when "application/json"
    content_type :json
    @validation.to_json
  end
  
end
