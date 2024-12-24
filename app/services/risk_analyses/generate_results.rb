class RiskAnalyses::GenerateResults  < ApplicationService
  def call(risk_analysis)
    # "commuterId": "COM-123",
    # "risk": 5500
    { commuterId: risk_analysis[:commuterId], risk: rand(1..6000) }
  end
end