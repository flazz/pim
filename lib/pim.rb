require 'rubygems'
gem 'schematron', '>= 0.0.2'
gem 'libxml-ruby', '>= 1.1.3'
gem 'nokogiri', '>=1.2.3'
gem 'syntax', '>=1.0.0'

require 'libxml'
require 'schematron'
require 'syntax/convertors/html'
require 'nokogiri'

include LibXML

module Pim

  NS = {
         'mets' => 'http://www.loc.gov/METS/',
         'premis' => 'info:lc/xmlns/premis-v2',
         'xlink' => 'http://www.w3.org/1999/xlink',
         'xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
       }

  def load_stron name
    schema = File.join(File.dirname(__FILE__), '..', 'schema', name)
    XML.default_line_numbers = true
    stron_doc = XML::Parser.file(schema).parse
    Schematron::Schema.new stron_doc
  end
  module_function :load_stron

  def self.generate_pim(premis, embedding)
    case embedding
      when 'container'

        # Validate PREMIS
        
        # Build list of warnings (if any)
        
        # Transform to PiM
        @premis = Nokogiri::XML.parse(premis)
        @files = @premis.xpath('//premis:object[@xsi:type="file"]', NS).map do |f|
                   {}
                 end
        pim = File.join(File.dirname(__FILE__), '..', 'views', 'pim.xml.erb')
        
        t = open pim do |io|
              string = io.read
              ERB.new(string, nil, '<>')
            end

        mets = t.result binding

        # Make it pretty
        convertor = Syntax::Convertors::HTML.for_syntax "xml"
        convertor.convert(mets, false)
        
      when 'buckets'
        "TODO"
      else
        "query parameter embed_as must be 'container' or 'buckets'"
    end
  end

  PIM_STRON = load_stron "pim.stron"

  class Validation

    def initialize src
      @src = src
    end

    def formedness

      begin
        parser = XML::Parser.string @src
        parser.parse
        nil
      rescue => e
        e.message
      end

    end

    def validity
      output = nil
      Tempfile.open 'xml' do |tio|
        tio.write @src
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

    def conforms_to_bp
      parser = XML::Parser.string @src
      doc = parser.parse
      PIM_STRON.validate doc
    end

    def results
      results = {}
      results[:formedness] = formedness

      if results[:formedness].nil?
        results[:validity] = validity

        if results[:validity].nil?
          results[:conforms_to_bp] = conforms_to_bp
        end

      end

      results
    end
    
  end
  
end
