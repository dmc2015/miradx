# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommuterAction, type: :model do
  it 'inherits from RiskAnalysis' do
    expect(described_class.superclass).to eq(RiskAnalysis)
  end

  it 'can be created using risk analysis factory' do
    commuter_action = create(:risk_analysis)
    expect(commuter_action).to be_valid
    expect(commuter_action).to be_a(RiskAnalysis)
  end
end
