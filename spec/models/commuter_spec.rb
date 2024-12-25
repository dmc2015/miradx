# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commuter, type: :model do
  describe 'associations' do
    it { should have_many(:risk_analyses) }
    it { should have_many(:actions).through(:risk_analyses) }
  end

  describe 'validations' do
    subject { build(:commuter) }

    it { should validate_presence_of(:commuter_id) }
    it { should validate_uniqueness_of(:commuter_id) }
  end
end
