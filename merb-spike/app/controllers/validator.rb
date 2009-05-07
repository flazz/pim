require 'open-uri'
require 'xml/libxml'
require 'schematron'

class Validator < Application
  include LibXML
  
  # TODO: Nicer to_json method for results hash
  provides :xml, :json
  
  # Validate by URI
  def validate_uri
    raw_url = params['document']
    raise BadRequest if raw_url.nil? or raw_url.strip.empty?

    url = CGI::unescape raw_url

    @results = open(url) { |f| validate f }

    display @results, 'validator/validate'
  end
  
  # Validate by direct input or file upload
  def validate_data
    raw = params['document']
    raise BadRequest if raw.nil? or raw.empty?
  
    case raw.class.name
    when 'Mash'
      raw = raw[:tempfile]
    when 'String'
      raw = StringIO.new(raw)
    end
  
    @results = validate raw
    display @results, 'validator/validate'
  end
  
  # Validate parsed XML
  def validate(raw_io)

    # Load the schematron
    # TODO: Refactor this to run once at load time
    schema = File.join("schema", "pim.stron")
    stron_parser = XML::Parser.file schema
    stron_doc = stron_parser.parse
  
    XML.default_line_numbers = true
    stron = Schematron::Schema.new(stron_doc)

    # TODO catch errors for well formedness
    instance_parser = XML::Parser.io raw_io
    instance_doc = instance_parser.parse

    # TODO validate the xml against the xml schema
  
    # validate against schematron PiM
    stron.validate instance_doc    
  end

end