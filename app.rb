require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'erb'

require 'open-uri'
require 'cgi'
require 'net/http'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'validation'
require 'xslt'

configure do
  XML::Error.set_handler(&XML::Error::QUIET_HANDLER)
  include Pim
end

helpers do

  # Common handler for conversion results
  def handle_conversion src

    # validate incoming src, for now 400 if bad
    v = Validation.new(src).validity
    unless v.flatten.empty?
      @flash = "Cannot convert: validation errors exist"
      @results = Validation.new(src).results
      body = erb(:'validate/results')
      halt 400, body
    end

    doc = XML::Parser.string(src).parse
    Pim.cleanup! doc

    case doc.root.namespaces.namespace.href
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
      halt 400, 'document must either be PREMIS version 2.0 or METS'
    end
  end

  # Check that a parameter is defined
  def check_parameter(*parameter)
    parameter.each do |p|
      halt 400, "query parameter #{p} is required" unless params[p]
    end
  end

  # Check that a parameter is not an empty string
  def check_parameter_value(*parameter)
    parameter.each do |p|
      v = params[p]
      if v.is_a? String and v.strip.empty?
        halt 400, "query parameter #{p} should not be empty"
      end
    end
  end

  # Update identifiers from XML provided by the description service
  def update_identifiers(src, o_name)

    # Check ieid information
    if params['ieid_type'].nil? ^ params['ieid_value'].nil?
      halt 400, "both parameters ieid_type and ieid_value must be provided"
    end

    doc = XML::Parser.string(src).parse
    Pim.modify_object_id!(doc, params['id_type'], params['id_value'])

    # Update ieid if it exists
    if params['ieid_type'] and params['ieid_value']
      if params['ieid_type'].strip.empty? ^ params['ieid_value'].strip.empty?
        halt 400, "both parameters ieid_type and ieid_value must be provided"
      else
        unless params['ieid_type'].strip.empty?
          Pim.add_ieid!(doc, params['ieid_type'], params['ieid_value'])
        end
      end
    end

    # Update originalName
    Pim::modify_original_name! doc, o_name

    Pim::splice_schemalocation! doc

    content_type 'application/xml', :charset => 'utf-8'
    doc.to_s
  end

end

# index
get '/' do
  erb :index
end

# validate PiM
get '/validate' do
  erb :'validate/index'
end

get '/validate/results' do
  check_parameter 'document'
  url = CGI::unescape params['document'].strip

  src = begin
          open(url) { |f| f.read }
        rescue => e
          halt 400, "cannot get url: #{url}, #{e.message}"
        end

  @results = Validation.new(src).results
  erb :'validate/results'
end

post '/validate/results' do
  check_parameter 'document'

  src = case params['document']
        when Hash
          params['document'][:tempfile].read # XXX could be a ram hog
        when String
          params['document']
        end
  check_parameter_value 'document'
  @results = Validation.new(src).results
  erb :'validate/results'
end

# convert PREMIS to PiM
get '/convert' do
  erb :'convert/index'
end

get '/convert/results' do
  check_parameter 'document'
  url = params['document'].strip

  src = begin
          open(url) { |f| f.read }
        rescue => e
          halt 400, "cannot get url: #{url}, #{e.message}"
        end

  handle_conversion src
end

post '/convert/results' do
  check_parameter 'document'

  src = case params['document']
        when Hash
          params['document'][:tempfile].read # XXX could be a ram hog
        when String
          params['document']
        end

  handle_conversion src
end

get '/resources/?' do
  erb :resources
end

# Describe a file in PREMIS
get '/describe' do
  erb :'describe/index'
end

get '/describe/results' do
  check_parameter 'document', 'id_type', 'id_value'
  check_parameter_value 'id_type', 'id_value'

  url = CGI::unescape params['document'].strip

  src = begin
          open(url) { |f| f.read }
        rescue => e
          halt 400, "cannot get url: #{url}, #{e.message}"
        end

  ext = params['document'].split('/').last.split('.').last

  r = Net::HTTP.post_form(URI.parse('http://description.fcla.edu/description'),
                          { 'document' => src, 'extension' => ext })

  case r
  when Net::HTTPSuccess
    o_name = params[:document]
    update_identifiers(r.body, o_name)
  else
    r.error!
  end

end

post '/describe/results' do
  check_parameter 'document', 'id_type', 'id_value'
  check_parameter_value 'id_type', 'id_value'

  src = params['document'][:tempfile].read
  ext = params['document'][:filename].split('.').last
  r = Net::HTTP.post_form(URI.parse('http://description.fcla.edu/description'),
                          { 'document' => src, 'extension' => ext })
  case r
  when Net::HTTPSuccess
    o_name = params['document'][:filename]
    update_identifiers(r.body, o_name)
  else
    r.error!
  end

end
