module Admin
  class BaseController < ApplicationController
    include AdminAuthorization

    layout "admin"
  end
end
