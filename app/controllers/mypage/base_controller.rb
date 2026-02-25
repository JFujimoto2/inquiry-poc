module Mypage
  class BaseController < ApplicationController
    skip_before_action :require_authentication
    include CustomerAuthentication

    layout "mypage"
  end
end
