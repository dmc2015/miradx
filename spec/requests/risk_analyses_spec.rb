# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RiskAnalyses', type: :request do
  describe 'POST /risk_analyses' do
    let(:base_payload) do
      {
        commuterId: 'COM-123',
        actions: [
          {
            timestamp: '2024-01-01 10:00:00',
            action: 'walked',
            unit: 'mile',
            quantity: 1.0
          }
        ]
      }
    end

    context 'with valid parameters' do
      it 'creates records and returns risk analysis' do
        expect do
          post '/risk_analyses', params: base_payload
        end.to change(RiskAnalysis, :count).by(1)
                                           .and change(Action, :count).by(1)
                                                                      .and change(Commuter, :count).by(1)

        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          'commuterId' => 'COM-123',
          'risk' => (1.0 * Action::UNIT_MAPPING[:mile] * 250).to_i
        )
      end

      it 'reuses existing commuter' do
        create(:commuter, commuter_id: 'COM-123')

        expect do
          post '/risk_analyses', params: base_payload
        end.not_to change(Commuter, :count)

        expect(response).to have_http_status(:success)
      end

      context 'with multiple actions' do
        let(:multi_action_payload) do
          {
            commuterId: 'COM-123',
            actions: [
              {
                timestamp: '2024-01-01 10:00:00',
                action: 'walked',
                unit: 'mile',
                quantity: 1.0
              },
              {
                timestamp: '2024-01-01 11:00:00',
                action: 'climbed',
                unit: 'floor',
                quantity: 2.0
              }
            ]
          }
        end

        it 'processes all actions correctly' do
          expect do
            post '/risk_analyses', params: multi_action_payload
          end.to change(Action, :count).by(2)
                                       .and change(RiskAnalysis, :count).by(2)

          expect(response).to have_http_status(:success)

          expected_risk = (
            1.0 * Action::UNIT_MAPPING[:mile] * 250 +
            2.0 * Action::UNIT_MAPPING[:floor] * 250
          ).to_i

          json_response = JSON.parse(response.body)
          expect(json_response['risk']).to eq(expected_risk)
        end
      end
    end

    context 'with invalid parameters' do
      it 'handles missing commuterId' do
        post '/risk_analyses', params: base_payload.except(:commuterId)
        expect(response).to have_http_status(:bad_request)
      end

      it 'handles missing actions array' do
        post '/risk_analyses', params: base_payload.except(:actions)

        expect(response).to have_http_status(:bad_request)
      end

      context 'with invalid action parameters' do
        it 'handles missing timestamp' do
          payload = base_payload.deep_dup
          payload[:actions][0].delete(:timestamp)

          post '/risk_analyses', params: payload

          expect(response).to have_http_status(:bad_request)
        end

        it 'handles missing action name' do
          payload = base_payload.deep_dup
          payload[:actions][0].delete(:action)

          post '/risk_analyses', params: payload
          expect(response).to have_http_status(:bad_request)
        end

        it 'handles missing unit' do
          payload = base_payload.deep_dup
          payload[:actions][0].delete(:unit)

          post '/risk_analyses', params: payload

          expect(response).to have_http_status(:bad_request)
        end

        it 'handles missing quantity' do
          payload = base_payload.deep_dup
          payload[:actions][0].delete(:quantity)

          post '/risk_analyses', params: payload

          expect(response).to have_http_status(:bad_request)
        end

        it 'handles invalid unit type' do
          payload = base_payload.deep_dup
          payload[:actions][0][:unit] = 'invalid_unit'

          post '/risk_analyses', params: payload

          expect(response).to have_http_status(:bad_request)
        end

        it 'handles invalid timestamp format' do
          payload = base_payload.deep_dup
          payload[:actions][0][:timestamp] = 'invalid-timestamp'

          post '/risk_analyses', params: payload

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'handles negative quantity' do
          payload = base_payload.deep_dup
          payload[:actions][0][:quantity] = -1

          post '/risk_analyses', params: payload

          expect(response).to have_http_status(:bad_request)
        end

        it 'handles zero quantity' do
          payload = base_payload.deep_dup
          payload[:actions][0][:quantity] = 0

          post '/risk_analyses', params: payload

          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'with timestamp validations' do
        it 'handles timestamps on different days' do
          payload = base_payload.deep_dup
          payload[:actions] << {
            timestamp: '2024-01-02 10:00:00',
            action: 'walked',
            unit: 'mile',
            quantity: 1.0
          }

          post '/risk_analyses', params: payload

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
