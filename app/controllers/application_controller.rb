class ApplicationController < ActionController::API

  rescue_from ActiveRecord::RecordNotFound do
    render json: {status: 'FAILURE', data: {message: 'Record Not Found'}}
  end

  def render_response(response)
    render json: response, status: :ok
  end

  def get_response(service, service_params = [])
  	service_params == [] ? render_response(service.new.call) : render_response(service.new(service_params).call)
  end

  def authenticate_user
    render json: {status: 'FAILURE', data: {message: 'Invalid Token'}} unless current_user
  end

  def current_user
    @current_user ||= User.where(remember_token: params[:remember_token]).first
    User.current_user = @current_user
  end

  def authorized_user?
    render json: {status: 'FAILURE', data: {message: 'Not Authorized'}} unless rule_exists?
  end

  def rule_exists?
    Rule.exists?(:user_type => User.user_types[current_user.user_type], :controller_name => controller_name, :action_name => action_name)
  end
end
