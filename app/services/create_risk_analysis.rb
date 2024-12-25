class CreateRiskAnalysis
  class ValidationError < StandardError; end

  def initialize(params)
    @params = params
  end

  def execute
    Rails.logger.debug "Service params: #{@params.inspect}"
    validate_dates

    ActiveRecord::Base.transaction do
      create_risk_analyses
    end

    calculate_risk
  rescue StandardError => e
    Rails.logger.error "Service error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end

  private

  attr_reader :params

  def validate_dates
    return if Action.valid_dates?(params[:actions])

    raise ValidationError, 'all timestamps must be on the same day'
  end

  def create_risk_analyses
    commuter = Commuter.find_or_create_by!(commuter_id: params[:commuter_id])
    Rails.logger.debug "Created/found commuter: #{commuter.inspect}"

    actions = params[:actions].map do |action_params|
      action = Action.create!(action_params)
      Rails.logger.debug "Created action: #{action.inspect}"
      action
    end

    @risk_analyses = actions.map do |action|
      analysis = RiskAnalysis.create!(commuter: commuter, action: action)
      Rails.logger.debug "Created risk analysis: #{analysis.inspect}"
      analysis
    end
  end

  def calculate_risk
    RiskCalculator::GenerateResults.call(
      RiskAnalysis.where(id: @risk_analyses.map(&:id))
                 .includes(:action, :commuter)
    )
  end
end
