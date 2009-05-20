require 'sinatra'
require 'open-uri'
require 'libxml'
require 'cgi'
require 'schematron'

include LibXML

module Pim

  # load the PREMIS in METS schematron
  schema = File.join(File.dirname(__FILE__), "schema", "pim.stron")
  XML.default_line_numbers = true
  stron_doc = XML::Parser.file(schema).parse
  PIM_STRON = Schematron::Schema.new stron_doc

  # The Sinatra App
  class App < Sinatra::Default

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
        PIM_STRON.validate doc
      end

      erb :validate
    end

    post '/validate' do
      halt 400, "POST variable document is required" unless params['document']

      @results = begin
                   doc = case params['document']
                         when Hash
                           XML::Parser.io params['document'][:tempfile]
                         when String
                           XML::Parser.string params['document']
                         end.parse
                   PIM_STRON.validate doc
                 rescue => e
                   [e.message]
                 end

      erb :validate
    end

  end

end

if __FILE__ == $0
  Pim::App.run!
end
