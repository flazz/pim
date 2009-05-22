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

  # return a formedness error if one exists
  def formedness src

    begin
      parser = XML::Parser.string src
      parser.parse
      nil
    rescue => e
      e.message
    end

  end
  module_function :formedness

  # return any validity errors
  def validity src
    output = nil
    Tempfile.open 'xml' do |tio|
      tio.write src
      tio.flush
      output = `java -Dfile=#{tio.path} -jar xmlvalidator.jar`
    end

    if output =~ /Warnings: \d+\n.*?Errors: \d+\n(.*?)Fatal Errors: \d+\n.*?/m
      error_text = $1

      errors = error_text.split("\n").map do |e|
        parts = e.split ": ", 3
        { :line => parts[0], :message => parts[2] }
      end

      errors.empty? ? nil : errors

    else
      raise "invalid output while validating"
    end

  end
  module_function :validity

  # return any schematron errrors
  def conforms_to_bp src
    parser = XML::Parser.string src
    doc = parser.parse
    PIM_STRON.validate doc
  end
  module_function :conforms_to_bp

  # return a hash of cascading validation results
  def validate src
    results = {}
    results[:formedness] = formedness(src)

    if results[:formedness].nil?
      results[:validity] = validity(src)

      if results[:validity].nil?
        results[:conforms_to_bp] = conforms_to_bp(src)
      end

    end

    results
  end
  module_function :validate

  # The Sinatra App
  class App < Sinatra::Default

    get '/' do
      @title = "PREMIS in METS Validator"
      erb :index
    end

    get '/validate' do
      halt 400, "query parameter document is required" unless params['document']
      @title = "Validation Results"
      url = CGI::unescape params['document']
      @results = open(url) { |f| Pim::validate f }
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

      @results = Pim::validate src
      erb :validate
    end

  end

end

Pim::App.run! if __FILE__ == $0
