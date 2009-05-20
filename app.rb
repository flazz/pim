require 'sinatra'
require 'open-uri'
require 'libxml'
require 'cgi'
require 'schematron'

include LibXML

# Load the PiM schematron
configure do
  schema = File.join(File.dirname(__FILE__), "schema", "pim.stron")
  stron_parser = XML::Parser.file schema
  stron_doc = stron_parser.parse
  XML.default_line_numbers = true
  set :stron, Schematron::Schema.new(stron_doc)
end

class Pim < Sinatra::Default

  get '/' do
    @title = "PREMIS in METS Validator"
    puts options.stron
    erb :index
  end

  get '/validate' do
    halt 400, "query parameter document is required" unless params['document']
    url = CGI::unescape params['document']

    @results = open(url) do |f|
      parser = XML::Parser.io io
      doc = parser.parse
      stron.validate doc
    end

    erb :validate
  end

  post '/validate' do
    halt 400, "POST variable document is required" unless params['document']

    doc = case params['document']
          when Hash
            XML::Parser.io params['document'][:tempfile]
          when String
            XML::Parser.string params['document']
          end.parse

    @results = stron.validate doc
    erb :validate
  end

end

