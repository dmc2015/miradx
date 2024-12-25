require 'rails_helper'

RSpec.describe RiskCalculator::GenerateResults do
  describe '#call' do
    let(:commuter) { create(:commuter) }

    context 'with single action' do
      let(:action) { create(:action, unit: 'mile', quantity: 2.0) }
      let(:risk_analysis) { create(:risk_analysis, commuter: commuter, action: action) }
      let(:risk_analyses) { [risk_analysis] }

      it 'calculates correct risk score' do
        result = described_class.call(risk_analyses)
        expected_score = (2.0 * Action::UNIT_MAPPING[:mile] * 250).to_i

        expect(result).to eq({
                               commuter_id: commuter.commuter_id,
                               risk: expected_score
                             })
      end
    end

    context 'with multiple actions' do
      let(:actions) do
        [
          create(:action, unit: 'mile', quantity: 1.0),
          create(:action, unit: 'floor', quantity: 2.0),
          create(:action, unit: 'minute', quantity: 3.0),
          create(:action, unit: 'quantity', quantity: 4.0)
        ]
      end

      let(:risk_analyses) do
        actions.map { |action| create(:risk_analysis, commuter: commuter, action: action) }
      end

      it 'calculates correct total risk score' do
        result = described_class.call(risk_analyses)

        expected_score = (
          1.0 * Action::UNIT_MAPPING[:mile] * 250 +
          2.0 * Action::UNIT_MAPPING[:floor] * 250 +
          3.0 * Action::UNIT_MAPPING[:minute] * 250 +
          4.0 * Action::UNIT_MAPPING[:quantity] * 250
        ).to_i

        expect(result).to eq({
                               commuter_id: commuter.commuter_id,
                               risk: expected_score
                             })
      end
    end
  end
end
