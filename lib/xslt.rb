gem 'libxslt-ruby', '>= 0.9.1'

require 'libxslt'
require 'libxml'

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
  
  # Clean up any ID/IDRefs that would conflict with our translation
  def cleanup! xml
    ns = { 'pre' => 'info:lc/xmlns/premis-v2' }
    
    conflicts = xml.find("//pre:*[starts-with(@xmlID, 'agent-')]", ns).to_a + 
                xml.find("//pre:*[starts-with(@xmlID, 'object-')]", ns).to_a +
                xml.find("//pre:*[starts-with(@xmlID, 'event-')]", ns).to_a +
                xml.find("//pre:*[starts-with(@xmlID, 'bitstream-')]", ns).to_a +
                xml.find("//pre:*[starts-with(@xmlID, 'representation-')]", ns).to_a +
                xml.find("//pre:*[@xmlID='DPMD1']", ns).to_a +
                xml.find("//pre:*[@xmlID='PREMIS_AMD']", ns).to_a
                            
    unless conflicts.empty?
      
      # prepend all IDs with 'premis_'
      xml.find("//pre:*[@xmlID]", ns).each do |c| 
        c['xmlID'] = "premis_#{c['xmlID']}"
      end
      
      # modify corresponding IDRefs
      ['RelEventXmlID', 'RelObjectXmlID', 'LinkObjectXmlID', 'LinkEventXmlID',
       'LinkAgentXmlID', 'LinkPermissionStatementXmlID'].each do |a|
        
        xml.find("//pre:*[@#{a}]", ns).each do |node|
          new_idref = node[a].split.map { |s| "premis_#{s}" }
          node[a] = new_idref * ' '
        end

      end
    
    end
    
    xml
  end
  
  module_function :load_xslt
  module_function :cleanup!
  
  PREMIS_TO_PIM_CONTAINER_XSLT = load_xslt "pim_container.xsl"
  PREMIS_TO_PIM_BUCKETS_XSLT = load_xslt "pim_buckets.xsl"
  PIM_TO_PREMIS_XSLT = load_xslt "pim_to_premis.xsl"
end
