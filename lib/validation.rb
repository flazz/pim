gem 'libxml-ruby', '>= 1.1.3'

require 'libxml'
require 'stron'
require 'rjb'

include LibXML

module Pim

  class Validation

    def initialize src
      @src = src

      # setup rjb validator
      jar_file = File.join(File.dirname(__FILE__), '..', 'ext', 'xmlvalidator.jar')
      ENV['CLASSPATH'] = if ENV['CLASSPATH']
        "#{jar_file}:#{ENV['CLASSPATH']}"
      else
        jar_file
      end
      
      # can probably make this a class variable
      @j_File = Rjb.import 'java.io.File' 
      @j_Validator = Rjb.import 'edu.fcla.da.xml.Validator'
      @jvalidator = @j_Validator.new
    end

    def validity
      
      tio = Tempfile.open 'xml'
      tio.write @src
      tio.flush
      tio.close
      
      # java code
      jfile = @j_File.new tio.path
      jchecker = @jvalidator.validate jfile
      
      # formedness errors
      fatals = if jchecker.getFatals.size > 0
                 (0...jchecker.getFatals.size).map do |n|
                   f = jchecker.getFatals.elementAt(n)
                   { :line => f.getLineNumber, 
                     :message => f.getMessage, 
                     :column => f.getColumnNumber }
                 end
               end

      # validation errors
      errors = if jchecker.getErrors.size > 0
                 (0...jchecker.getErrors.size).map do |n|
                    e = jchecker.getErrors.elementAt(n)
                    { :line => e.getLineNumber, 
                      :message => e.getMessage,
                      :column => e.getColumnNumber }
                 end
               end
      
      tio.unlink

     [fatals, errors]
    end

    def conforms_to_bp
      parser = XML::Parser.string @src
      doc = parser.parse
      PIM_STRON.validate doc
    end

    def results
      results = {}
      results[:formedness], results[:validity] = validity

      if results[:validity].nil? and results[:formedness].nil?
        results[:conforms_to_bp] = conforms_to_bp
      end

      results
    end

  end

end
