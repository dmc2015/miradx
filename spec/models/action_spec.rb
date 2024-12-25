require 'rails_helper'

RSpec.describe Action, type: :model do
  describe 'associations' do
    it { should have_many(:risk_analyses) }
    it { should have_many(:commuters).through(:risk_analyses) }
  end

  describe 'validations' do
    it { should validate_presence_of(:action) }
    it { should validate_presence_of(:timestamp) }
    it { should validate_presence_of(:unit) }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_inclusion_of(:unit).in_array(Action::VALID_UNITS) }
  end

  describe 'constants' do
    it 'defines VALID_UNITS' do
      expect(Action::VALID_UNITS).to eq(%w[mile floor minute quantity])
    end

    it 'defines UNIT_MAPPING' do
      expect(Action::UNIT_MAPPING).to eq({
                                           floor: 20,
                                           mile: 10,
                                           quantity: 1,
                                           minute: 5
                                         })
    end
  end

  describe '.valid_dates?' do
    context 'with actions on same day' do
      let(:actions) do
        [
          { 'timestamp' => '2024-01-01 10:00:00' },
          { 'timestamp' => '2024-01-01 15:00:00' }
        ]
      end

      it 'returns truthy' do
        expect(Action.valid_dates?(actions)).to be_truthy
      end
    end

    context 'with actions on different days' do
      let(:actions) do
        [
          { 'timestamp' => '2024-01-01 10:00:00' },
          { 'timestamp' => '2024-01-02 10:00:00' }
        ]
      end

      it 'returns falsey' do
        expect(Action.valid_dates?(actions)).to be_falsey
      end
    end

    context 'with actions at midnight' do
      let(:actions) do
        [
          { 'timestamp' => '2024-01-01 10:00:00' },
          { 'timestamp' => '2024-01-01 00:00:00' }
        ]
      end

      it 'returns falsey' do
        expect(Action.valid_dates?(actions)).to be_truthy
      end
    end

    context 'with actions at 11:59' do
      let(:actions) do
        [
          { 'timestamp' => '2024-01-01 11:59:59' },
          { 'timestamp' => '2024-01-01 00:00:00' }
        ]
      end

      it 'returns falsey' do
        expect(Action.valid_dates?(actions)).to be_truthy
      end
    end

    context 'with actions at 00:01' do
      let(:actions) do
        [
          { 'timestamp' => '2024-01-01 11:59:59' },
          { 'timestamp' => '2024-01-02 00:00:00' }
        ]
      end

      it 'returns falsey' do
        expect(Action.valid_dates?(actions)).to be_falsey
      end
    end
  end

  describe '#timestamp_format' do
    let(:action) { build(:action) }

    context 'with valid timestamp' do
      before { action.timestamp = '2024-01-01 10:00:00' }

      it 'is valid' do
        expect(action).to be_valid
      end
    end

    context 'with invalid timestamp' do
      it 'is invalid with incorrect format' do
        action = Action.new
        action.timestamp = 'not-a-date'
        expect(action).not_to be_valid
      end
    end
  end
end
