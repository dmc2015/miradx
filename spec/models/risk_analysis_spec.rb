require 'rails_helper'

RSpec.describe RiskAnalysis, type: :model do
  describe 'associations' do
    it { should belong_to(:commuter) }
    it { should belong_to(:action) }
  end
end
