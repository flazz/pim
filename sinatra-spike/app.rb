require 'sinatra'
require 'open-uri'
require 'libxml'
require 'cgi'
require 'schematron'
require 'json'

mime :xml, 'application/xml'
mime :json, 'application/json'

include LibXML

# Load the PiM schematron
configure do
  schema = File.join(File.dirname(__FILE__), "schema", "pim.stron")
  stron_parser = XML::Parser.file schema
  stron_doc = stron_parser.parse
  
  XML.default_line_numbers = true
  set :stron, Schematron::Schema.new(stron_doc)
end

# The Sinatra way
helpers do

  # Validate PiM
  def validate(raw_io, stron)

    # TODO catch errors for well formedness
    instance_parser = XML::Parser.io raw_io
    instance_doc = instance_parser.parse

    # TODO validate the xml against the xml schema
  
    # validate against schematron PiM
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
      erb :validate_xml, :layout => false
    when "application/json"
      content_type :json
      @results.to_json
    end
  
  end

end


# Routes
get '/' do
  @title = "PiM"
  puts options.stron
  erb :index
end

get '/validate' do
  raw_url = params['document']
  halt 400, "query parameter document is required" if raw_url.nil?

  url = CGI::unescape raw_url
  
  @results = open(url) do |f|
    validate f, options.stron
  end

  render_requested_format

end

post '/validate' do
  raw = params['document']
  halt 400, "POST variable document is required" if raw.nil?
  
  case raw.class.name
  when 'Hash'
    puts raw[:tempfile].class
    raw = raw[:tempfile]
  when 'String'
    raw = StringIO.new(raw)
  end
  
  @results = validate raw, options.stron
  render_requested_format
  
end

