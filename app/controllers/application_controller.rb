class ApplicationController < ActionController::Base
  rescue_from ActionController::ParameterMissing, with: :handle_missing_parameter
  rescue_from ActiveRecord::RecordInvalid, with: :handle_missing_parameter
  rescue_from Date::Error, with: :handle_missing_parameter
  rescue_from ActiveRecord::RecordInvalid, with: :handle_missing_parameter

  private

  def handle_missing_parameter(e)
    render json: { error: e.message }, status: :bad_request
  end
end
