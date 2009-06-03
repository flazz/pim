require 'rubygems'

gem 'schematron', '>= 0.0.2'
gem 'libxml-ruby', '>= 1.1.3'
gem 'libxslt-ruby', '>= 0.9.1'

require 'libxml'
require 'libxslt'
require 'schematron'

include LibXML
include LibXSLT

module Pim

  # schematron
  def load_stron name
    schema = File.join(File.dirname(__FILE__), '..', 'schema', name)
    XML.default_line_numbers = true
    doc = XML::Parser.file(schema).parse
    Schematron::Schema.new doc
  end
  module_function :load_stron
  
  PIM_STRON = load_stron "pim.stron"
  
  # transformations
  def load_xslt name
    transform = File.join(File.dirname(__FILE__), '..', 'xsl', name)
    doc = XML::Parser.file(transform).parse
    XSLT::Stylesheet.new doc
  end
  module_function :load_xslt
  
  PREMIS_TO_PIM_CONTAINER_XSLT = load_xslt "pim_container.xsl"

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
        jarfile = File.join(File.dirname(__FILE__), '..', 'ext', 'xmlvalidator.jar')
        output = `java -Dfile=#{tio.path} -jar #{jarfile}`
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
