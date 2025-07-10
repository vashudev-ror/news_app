require 'pagy/extras/bootstrap' # if you're using Bootstrap

class ApplicationController < ActionController::Base
  include Pagy::Backend
end
