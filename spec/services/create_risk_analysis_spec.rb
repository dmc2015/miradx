# spec/services/create_risk_analysis_spec.rb
require 'rails_helper'

RSpec.describe CreateRiskAnalysis do
  let(:valid_params) do
    {
      commuter_id: 'COM-123',
      actions: [
        {
          timestamp: '2022-01-01 10:05:11',
          action: 'walked on sidewalk',
          unit: 'mile',
          quantity: 0.4
        },
        {
          timestamp: '2022-01-01 10:30:09',
          action: 'climbed stairs',
          unit: 'floor',
          quantity: 3
        }
      ]
    }
  end

  describe '#execute' do
    context 'with valid parameters' do
      it 'creates a commuter, actions, and risk analyses' do
        service = described_class.new(valid_params)

        expect do
          service.execute
        end.to change(Commuter, :count).by(1)
                                       .and change(Action, :count).by(2)
                                                                  .and change(RiskAnalysis, :count).by(2)
      end

      it 'returns expected risk calculation results' do
        service = described_class.new(valid_params)
        result = service.execute

        expect(result).to include(:commuter_id, :risk)
        expect(result[:commuter_id]).to eq('COM-123')
        expect(result[:risk]).to be_a(Numeric)
      end

      it 'reuses existing commuter' do
        create(:commuter, commuter_id: 'COM-123')
        service = described_class.new(valid_params)

        expect do
          service.execute
        end.to change(Commuter, :count).by(0)
                                       .and change(Action, :count).by(2)
                                                                  .and change(RiskAnalysis, :count).by(2)
      end
    end

    context 'with invalid parameters' do
      it 'raises ValidationError for timestamps on different days' do
        different_day_params = valid_params.deep_dup
        different_day_params[:actions][1][:timestamp] = '2022-01-02 10:30:09'
        service = described_class.new(different_day_params)

        expect do
          service.execute
        end.to raise_error(CreateRiskAnalysis::ValidationError, 'all timestamps must be on the same day')
          .and change(Commuter, :count).by(0)
          .and change(Action, :count).by(0)
          .and change(RiskAnalysis, :count).by(0)
      end

      it 'raises RecordInvalid for invalid unit' do
        invalid_unit_params = valid_params.deep_dup
        invalid_unit_params[:actions][0][:unit] = 'invalid_unit'
        service = described_class.new(invalid_unit_params)

        expect do
          service.execute
        end.to raise_error(ActiveRecord::RecordInvalid)
          .and change(Commuter, :count).by(0)
          .and change(Action, :count).by(0)
          .and change(RiskAnalysis, :count).by(0)
      end
    end

    context 'with transaction failures' do
      it 'rolls back all changes if action creation fails' do
        service = described_class.new(valid_params)
        allow(Action).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Action.new))

        expect do
          service.execute
        rescue ActiveRecord::RecordInvalid
          nil
        end.to change(Commuter, :count).by(0)
                                       .and change(Action, :count).by(0)
                                                                  .and change(RiskAnalysis, :count).by(0)
      end

      it 'rolls back all changes if risk analysis creation fails' do
        service = described_class.new(valid_params)
        allow(RiskAnalysis).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(RiskAnalysis.new))

        expect do
          service.execute
        rescue ActiveRecord::RecordInvalid
          nil
        end.to change(Commuter, :count).by(0)
                                       .and change(Action, :count).by(0)
                                                                  .and change(RiskAnalysis, :count).by(0)
      end

      it 'properly calculates risk using RiskCalculator' do
        service = described_class.new(valid_params)
        expected_result = { commuter_id: 'COM-123', risk: 100.0 }
        allow(RiskCalculator::GenerateResults).to receive(:call).and_return(expected_result)

        result = service.execute
        expect(result).to eq(expected_result)
      end
    end
  end
end
