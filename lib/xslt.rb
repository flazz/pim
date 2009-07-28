gem 'libxslt-ruby', '>= 0.9.1'

require 'libxslt'

include LibXSLT

module Pim
  
  # transformations
  def load_xslt name
    # transform = File.join(File.dirname(__FILE__), '..', 'public', 'xsl', name)
    # # doc = XML::Parser.file(transform).parse
    # doc = XML::Document.file transform, :base_uri => "/xsl"
    # XSLT::Stylesheet.new doc
    
    Dir.chdir(File.join(File.dirname(__FILE__), '..', 'public', 'xsl')) do
      doc = XML::Document.file name
      XSLT::Stylesheet.new doc
    end
    
  end
  
  module_function :load_xslt
  
  PREMIS_TO_PIM_CONTAINER_XSLT = load_xslt "pim_container.xsl"
  PREMIS_TO_PIM_BUCKETS_XSLT = load_xslt "pim_buckets.xsl"
  PIM_TO_PREMIS_XSLT = load_xslt "pim_to_premis.xsl"
end
