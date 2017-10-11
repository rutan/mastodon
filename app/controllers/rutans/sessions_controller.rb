# frozen_string_literal: true
module Rutans
  class SessionsController < ApplicationController
    def new
      if signed_in?
        redirect_to '/'
      else
        redirect_to user_google_oauth2_omniauth_authorize_path
      end
    end

    def destroy
      sign_out :user
      flash.delete(:notice)
      redirect_to '/'
    end

    def store_current_location
      # nothing to do
    end
  end
end
