# frozen_string_literal: true

class Auth::RegistrationsController < Devise::RegistrationsController
  layout :determine_layout

  before_action :check_enabled_registrations, only: [:new, :create]
  before_action :configure_sign_up_params, only: [:create]
  before_action :set_sessions, only: [:edit, :update]
  before_action :set_instance_presenter, only: [:new, :create, :update]

  def new
    if session['devise.auth_data']
      super
    else
      redirect_to about_path
    end
  end

  def create
    ActiveRecord::Base.transaction do
      super do
        if resource.id
          ::Rutans::AuthProvider.create!(
            name: session['devise.auth_data']['name'],
            uid: session['devise.auth_data']['uid'],
            user_id: resource.id
          )
          session['devise.auth_data'] = nil
        end
      end
    end
  end

  def destroy
    not_found
  end

  protected

  def build_resource(hash = nil)
    super(hash)
    resource.email = session['devise.auth_data']['email']
    resource.locale = I18n.locale
    resource.build_account if resource.account.nil?
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(account_attributes: [:username])
    end
  end

  def after_sign_up_path_for(_resource)
    new_user_session_path
  end

  def after_inactive_sign_up_path_for(_resource)
    new_user_session_path
  end

  def check_enabled_registrations
    redirect_to root_path if single_user_mode? || !Setting.open_registrations
  end

  private

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def determine_layout
    %w(edit update).include?(action_name) ? 'admin' : 'auth'
  end

  def set_sessions
    @sessions = current_user.session_activations
  end
end
