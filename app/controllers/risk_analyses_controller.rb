class RiskAnalysesController < ApplicationController
  before_action :create, only: [:valid_dates?, :risk_analysis_params]

  def create
    risk_analyses = RiskAnalysis.create(risk_analysis_params)
    risk_analysis_results = RiskAnalyses::GenerateResults.new(risk_analysis)
    JSONParseService.new(risk_analysis_results, [:commuterId, :risk])
  end
    
  private

  def valid_dates?
    earliest = nil
    latest = nil

    risk_analysis_params[:actions].each do |action|
      action_date = DateTime.strptime(action["timestamp"], "%Y-%m-%d %H:%M:%S")
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
    @risk_analysis_params ||= { commuterId: params[:commuterId], actions: actions }
  end
end



=begin
input
{
"commuterId": "COM-123",
"actions": [
{
"timestamp": "2022-01-01 10:05:11",
"action": "walked on sidewalk",
"unit": "mile",
"quantity": 0.4
},
{
"timestamp": "2022-01-01 10:30:09",
"action": "rode a shark",
"unit": "minute",
"quantity": 3
}
]
}
=end

=begin
output

{
"commuterId": "COM-123",
"risk": 5500
}
=end