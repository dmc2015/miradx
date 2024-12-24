module RiskCalculator
  class GenerateResults < ApplicationService
    def initialize(risk_analyses)
      @risk_analyses = risk_analyses # Store param in instance variable
    end

    def call

      micromorts_score = @risk_analyses.map do |risk_analysis|
        quantity = risk_analysis.action.quantity.to_f
        unit = Action::UNIT_MAPPING[risk_analysis.action.unit.to_sym]
        quantity * unit * 250
      end.sum.to_i

      { commuter_id: @risk_analyses.first.commuter.commuter_id, risk: micromorts_score }
    end
  end
end
