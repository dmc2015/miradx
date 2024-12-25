class RiskAnalysesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :valid_dates?, only: [:create]

  def create
    commuter = Commuter.find_or_create_by!(commuter_id: risk_analysis_params[:commuter_id])

    actions = Action.transaction do
      risk_analysis_params[:actions].map do |action_params|
        Action.create!(action_params)
      end
    end

    risk_analysis_ids = actions.map do |action|
      RiskAnalysis.create!(commuter: commuter, action: action).id
    end

    risk_analyses = RiskAnalysis.where(id: risk_analysis_ids)
                                .includes(:action, :commuter)

    risk_analyses_mort_results = RiskCalculator::GenerateResults.call(risk_analyses)

    risk_analysis_response = JsonParseService.parse(risk_analyses_mort_results, %i[commuter_id risk])
    render json: risk_analysis_response
  end

  private

  def valid_dates?
    return if Action.valid_dates?(risk_analysis_params[:actions])

    render json: { error: 'all timestamps must be on the same day' }, status: :unprocessable_entity
  end

  def risk_analysis_params
    return @risk_analysis_params if @risk_analysis_params

    params.require(:commuterId)
    actions = params.require(:actions).map do |action|
      action.permit(:timestamp, :action, :unit, :quantity)
    end

    actions.each do |action|
      raise ActionController::ParameterMissing.new('timestamp') if action[:timestamp].blank?
      raise ActionController::ParameterMissing.new('action') if action[:action].blank?
      raise ActionController::ParameterMissing.new('unit') if action[:unit].blank?
      raise ActionController::ParameterMissing.new('quantity') if action[:quantity].blank?
    end
    @risk_analysis_params ||= { commuter_id: params[:commuterId], actions: actions }
  end
end
