class RiskAnalysesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :create, only: %i[valid_dates? risk_analysis_params]

  def create
    commuter = Commuter.find_or_create_by!(commuter_id: risk_analysis_params[:commuter_id])

    actions = Action.transaction do
      risk_analysis_params[:actions].map do |action_params|
        Action.create!(action_params)
      end
    end

    risk_analysis_results = actions.map do |action|
      RiskAnalysis.create!(commuter: commuter, action: action)
    end

    # RiskAnalysis.create(risk_analysis_params)
    # risk_analysis_results = RiskAnalyses::GenerateResults.new(risk_analysis)
    # YOU MAPPED ABOVE SO YOU MIGHT NEED TO DO SOME CONFIGURATION
    # Might want to consider token management, maybe redis
    binding.pry
    JSONParseService.new(risk_analysis_results, %i[commuterId risk])
  end

  private

  def valid_dates?
    earliest = nil
    latest = nil

    risk_analysis_params[:actions].each do |action|
      action_date = DateTime.strptime(action['timestamp'], '%Y-%m-%d %H:%M:%S')
      if earliest.nil?
        earliest = action_date.midnight
        latest = action_date.tomorrow.midnight - 1.minute
        continue
      end
      return false if earliest >= action_date || latest <= action_date
    end
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

# input
{
  "commuterId": 'COM-123',
  "actions": [
    {
      "timestamp": '2022-01-01 10:05:11',
      "action": 'walked on sidewalk',
      "unit": 'mile',
      "quantity": 0.4
    },
    {
      "timestamp": '2022-01-01 10:30:09',
      "action": 'rode a shark',
      "unit": 'minute',
      "quantity": 3
    }
  ]
}

# output
#
# {
# "commuterId": "COM-123",
# "risk": 5500
# }
