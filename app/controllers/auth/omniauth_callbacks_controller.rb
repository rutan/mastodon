# frozen_string_literal: true

class Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env['omniauth.auth']
    @auth_provider = Rutans::AuthProvider.find_by(name: auth['provider'], uid: auth['uid'])

    if @auth_provider.present?
      user = @auth_provider.user
      sign_in user
      redirect_to after_sign_in_path_for(user)
    else
      session['devise.auth_data'] = {
        name: auth['provider'],
        uid: auth['uid'],
        email: auth['info']['email'],
      }
      redirect_to new_user_registration_path
    end
  end

  def after_sign_in_path_for(resource)
    last_url = stored_location_for(:user)

    if home_paths(resource).include?(last_url)
      root_path
    else
      last_url || root_path
    end
  end

  private

  def home_paths(resource)
    paths = [about_path]
    if single_user_mode? && resource.is_a?(User)
      paths << short_account_path(username: resource.account)
    end
    paths
  end
end
