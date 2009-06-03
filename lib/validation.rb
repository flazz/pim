gem 'libxml-ruby', '>= 1.1.3'

require 'libxml'
require 'stron'

include LibXML

module Pim

  class Validation

    def initialize src
      @src = src
    end

    def formedness

      begin
        parser = XML::Parser.string @src
        parser.parse
        nil                     # XXX this is a little unconventional
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
