# frozen_string_literal: true

class RiskAnalysesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    result = CreateRiskAnalysis.new(risk_analysis_params).execute
    render json: JsonParseService.parse(result, %i[commuter_id risk])
  end

  private

  def risk_analysis_params
    @risk_analysis_params ||= begin
      validate_required_parameters
      format_parameters
    end
  end

  def validate_required_parameters
    params.require(:commuterId)
    params.require(:actions)
  end

  def format_parameters
    {
      commuter_id: params[:commuterId],
      actions: format_actions
    }
  end

  def format_actions
    params[:actions].map do |action|
      formatted_action = action.permit(:timestamp, :action, :unit, :quantity)
      validate_action_parameters(formatted_action)
      formatted_action
    end
  end

  def validate_action_parameters(action)
    %i[timestamp action unit quantity].each do |param|
      raise ActionController::ParameterMissing, param if action[param].blank?
    end
  end
end
