require 'sinatra'
require 'open-uri'

mime :xml, 'application/xml'
mime :json, 'application/json'

get '/' do
  @title = "PiM"
  erb :index
end


get '/validate' do
  
  # unpack the xml
  raw_url = params['document']
  url = CGI::unescape raw_url
  raw_xml = open(url) { |f| f.read }
  

  # validate it

  # make the response
  
  # figure out the format
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

post '/validate' do
  # get from the params or body
  "echo: " + params[:document]
end

def validate(raw)
  # check for well formedness
  # validate the xml against the schema
  # validate against schematron PiM
end
