class Application < Merb::Controller

  # our index
  def show
    render :template => 'validator/index'
  end
  
end