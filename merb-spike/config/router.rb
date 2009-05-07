# Merb::Router is the request routing mapper for the merb framework.

Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  # RESTful routes
    
  # Adds the required routes for merb-auth using the password slice
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  match('/').to(:controller => 'application', :action =>'show')
  match("/validate", :method => :get).to(:controller => "validator", 
                                         :action => "validate_uri")
  match("/validate", :method => :post).to(:controller => "validator",
                                          :action => "validate_data")
  
end