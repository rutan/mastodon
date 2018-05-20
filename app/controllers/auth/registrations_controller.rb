# frozen_string_literal: true

class Auth::RegistrationsController < Devise::RegistrationsController
  layout :determine_layout

  before_action :check_enabled_registrations, only: [:new, :create]
  before_action :configure_sign_up_params, only: [:create]
  before_action :set_sessions, only: [:edit, :update]
  before_action :set_instance_presenter, only: [:new, :create, :update]

  def create
    super do
      session['devise.google_oauth2_data'] = nil if resource.persisted?
    end
  end

  def destroy
    not_found
  end

  protected

  def update_resource(resource, params)
    params[:password] = nil if Devise.pam_authentication && resource.encrypted_password.blank?
    super
  end

  def build_resource(hash = nil)
    if hash && session['devise.google_oauth2_data']
      begin
        ActiveRecord::Base.transaction do
          self.resource = User.find_for_oauth(
            JSON.parse(session['devise.google_oauth2_data'].to_json, object_class: OpenStruct)
          )
          resource.password = ''
          resource.encrypted_password = ''
          resource.locale = I18n.locale
          resource.account.username = hash[:account_attributes][:username]
          resource.account.save!
        end
      rescue ActiveRecord::RecordInvalid
        nil
      end
    else
      super(hash)

      resource.locale      = I18n.locale
      resource.invite_code = params[:invite_code] if resource.invite_code.blank?

      resource.build_account if resource.account.nil?
    end
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit({ account_attributes: [:username] }, :invite_code)
    end
  end

  def after_sign_up_path_for(_resource)
    new_user_session_path
  end

  def after_inactive_sign_up_path_for(_resource)
    new_user_session_path
  end

  def after_update_path_for(_resource)
    edit_user_registration_path
  end

  def check_enabled_registrations
    redirect_to root_path if single_user_mode? || !allowed_registrations?
  end

  def allowed_registrations?
    Setting.open_registrations || (invite_code.present? && Invite.find_by(code: invite_code)&.valid_for_use?)
  end

  def invite_code
    if params[:user]
      params[:user][:invite_code]
    else
      params[:invite_code]
    end
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
