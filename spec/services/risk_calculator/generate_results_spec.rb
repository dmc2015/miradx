RSpec.describe RiskCalculator::GenerateResults do
  let(:commuter) { create(:commuter, commuter_id: 'COM-123') }

  let(:actions) do
    [
      create(:action, unit: 'mile', quantity: 2.0),
      create(:action, unit: 'floor', quantity: 5.0)
    ]
  end

  let(:risk_analyses) do
    actions.map { |action| create(:risk_analysis, commuter: commuter, action: action) }
  end

  describe '#call' do
    it 'calculates total risk correctly' do
      result = described_class.call(risk_analyses)

      expect(result).to include(
        commuter_id: 'COM-123',
        risk: be_a(Integer)
      )
    end

    it 'handles empty risk analyses' do
      result = described_class.call([])

      expect(result).to eq(
        commuter_id: nil,
        risk: 0
      )
    end

    it 'rounds risk to integer' do
      result = described_class.call(risk_analyses)
      expect(result[:risk]).to be_a(Integer)
    end

    it 'uses correct base multiplier' do
      risk_analysis = create(:risk_analysis,
                             commuter: commuter,
                             action: create(:action, unit: 'mile', quantity: 1.0))

      unit_multiplier = Action::UNIT_MAPPING[:mile]
      expected_risk = (1.0 * unit_multiplier * described_class::BASE_RISK_MULTIPLIER).to_i

      result = described_class.call([risk_analysis])
      expect(result[:risk]).to eq(expected_risk)
    end

    it 'raises error for invalid unit' do
      action = create(:action)
      allow(action).to receive(:unit).and_return('invalid_unit')
      risk_analysis = create(:risk_analysis, commuter: commuter, action: action)

      expect do
        described_class.call([risk_analysis])
      end.to raise_error(ArgumentError, /Invalid unit/)
    end
  end
end
