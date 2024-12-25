# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActionController::ParameterMissing, with: :handle_missing_parameter
  rescue_from ActiveRecord::RecordInvalid, with: :handle_missing_parameter
  rescue_from Date::Error, with: :handle_missing_parameter
  rescue_from CreateRiskAnalysis::ValidationError, with: :handle_validation_error

  private

  def handle_missing_parameter(e)
    render json: { error: e.message }, status: :bad_request
  end

  def handle_validation_error(e)
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
