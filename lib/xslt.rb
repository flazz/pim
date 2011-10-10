#gem 'libxslt-ruby', '>= 0.9.1'

require 'libxslt'
require 'libxml'

include LibXSLT

XML.default_keep_blanks = false

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

  def modify_object_id!(xml, type, value)
    ns = { 'pre' => 'info:lc/xmlns/premis-v2', 'xsi' => 'http://www.w3.org/2001/XMLSchema-instance' }
        
    # update ids
    old_type = xml.find_first("//pre:object[@xsi:type='file']/pre:objectIdentifier/pre:objectIdentifierType", ns).content.strip
    old_value = xml.find_first("//pre:object[@xsi:type='file']/pre:objectIdentifier/pre:objectIdentifierValue", ns).content.strip
    
    types = ['objectIdentifierType', 'linkingObjectIdentifierType',
             'relatedObjectIdentifierType'].inject([]) do |list, t|
               list + xml.find("//pre:#{t}", ns).to_a
            end
            
    values = ['objectIdentifierValue', 'linkingObjectIdentifierValue',
              'relatedObjectIdentifierValue'].inject([]) do |list, v|
               list + xml.find("//pre:#{v}", ns).to_a
             end
    types.each { |t| t.content = t.content.sub old_type, type }
    values.each { |v| v.content = v.content.sub old_value, value }
        
  end
  
  def add_ieid!(xml, type, value)
    ns = { 'pre' => 'info:lc/xmlns/premis-v2' }

    object = xml.find("//pre:object", ns).first

    ieid_type = XML::Node.new("linkingIntellectualEntityIdentifierType", type)
    ieid_value = XML::Node.new("linkingIntellectualEntityIdentifierValue", value)
    ieid = XML::Node.new("linkingIntellectualEntityIdentifier")

    ieid << ieid_type
    ieid << ieid_value
       
    object << ieid
  end
  
  def modify_original_name!(xml, name)
    ns = { 'pre' => 'info:lc/xmlns/premis-v2' }
    o_name = xml.find_first("//pre:object/pre:originalName", ns)
    
    if o_name
      o_name.content = name
    else
      new_o_name = XML::Node.new "originalName", name
      object = xml.find_first "pre:object", ns
      insertion_point = object.find_first "pre:objectCharacteristics|pre:significantProperties|pre:preservationLevel|pre:objectIdentifier", ns
      
      if insertion_point
        insertion_point.next = XML::Node.new "originalName"
      else
        object << new_o_name
      end
      
    end
    
  end
  
  def splice_schemalocation! doc
    doc.root['xsi:schemaLocation'] = "info:lc/xmlns/premis-v2 http://www.loc.gov/standards/premis/premis.xsd"
  end
  
  module_function :load_xslt, :cleanup!, :modify_object_id!, :add_ieid!, :modify_original_name!, :splice_schemalocation!
  
  PREMIS_TO_PIM_CONTAINER_XSLT = load_xslt "pim_container.xsl"
  PREMIS_TO_PIM_BUCKETS_XSLT = load_xslt "pim_buckets.xsl"
  PIM_TO_PREMIS_XSLT = load_xslt "pim_to_premis.xsl"
end
