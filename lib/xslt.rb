gem 'libxslt-ruby', '>= 0.9.1'

require 'libxslt'

include LibXSLT

module Pim
  
  # transformations
  def load_xslt name
    transform = File.join(File.dirname(__FILE__), '..', 'xsl', name)
    doc = XML::Parser.file(transform).parse
    XSLT::Stylesheet.new doc
  end
  module_function :load_xslt
  
  PREMIS_TO_PIM_CONTAINER_XSLT = load_xslt "pim_container.xsl"
  
end
