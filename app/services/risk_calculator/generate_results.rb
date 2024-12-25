module RiskCalculator
  class GenerateResults < ApplicationService
    BASE_RISK_MULTIPLIER = 250

    def initialize(risk_analyses)
      @risk_analyses = risk_analyses
      @commuter_id = risk_analyses.first&.commuter&.commuter_id
    end

    def call
      return empty_result if @risk_analyses.empty?

      {
        commuter_id: @commuter_id,
        risk: calculate_total_risk
      }
    end

    private

    def calculate_total_risk
      @risk_analyses.sum { |analysis| calculate_individual_risk(analysis) }.to_i
    end

    def calculate_individual_risk(risk_analysis)
      quantity = risk_analysis.action.quantity.to_f
      unit_multiplier = fetch_unit_multiplier(risk_analysis.action.unit)

      quantity * unit_multiplier * BASE_RISK_MULTIPLIER
    end

    def fetch_unit_multiplier(unit)
      Action::UNIT_MAPPING.fetch(unit.to_sym) do
        raise ArgumentError, "Invalid unit: #{unit}"
      end
    end

    def empty_result
      {
        commuter_id: nil,
        risk: 0
      }
    end
  end
end
