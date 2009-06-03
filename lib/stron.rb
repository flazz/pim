gem 'schematron', '>= 0.0.2'

require 'libxml'
require 'schematron'

include LibXML

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
  
end
