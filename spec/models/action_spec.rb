# spec/models/action_spec.rb
require 'rails_helper'

RSpec.describe Action, type: :model do
  describe 'validations' do
    subject { build(:action) }

    it { should validate_presence_of(:action) }
    it { should validate_presence_of(:timestamp) }
    it { should validate_presence_of(:unit) }
    it { should validate_presence_of(:quantity) }
    it { should validate_inclusion_of(:unit).in_array(Action::VALID_UNITS) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
  end

  describe '.valid_dates?' do
    let(:base_timestamp) { '2022-01-01 10:00:00' }

    let(:same_day_actions) do
      [
        { timestamp: '2022-01-01 10:00:00' },
        { timestamp: '2022-01-01 15:00:00' },
        { timestamp: '2022-01-01 23:59:59' }
      ]
    end

    let(:different_day_actions) do
      [
        { timestamp: '2022-01-01 23:59:59' },
        { timestamp: '2022-01-02 00:00:00' }
      ]
    end

    context 'with valid inputs' do
      it 'returns false for empty array' do
        expect(described_class.valid_dates?([])).to be false
      end

      it 'returns true for single action' do
        expect(described_class.valid_dates?([{ timestamp: base_timestamp }])).to be true
      end

      it 'returns true for multiple actions on same day' do
        expect(described_class.valid_dates?(same_day_actions)).to be true
      end

      it 'handles symbol keys' do
        actions = same_day_actions.map { |a| { timestamp: a[:timestamp] } }
        expect(described_class.valid_dates?(actions)).to be true
      end
    end

    context 'with invalid inputs' do
      it 'returns false for actions on different days' do
        expect(described_class.valid_dates?(different_day_actions)).to be false
      end

      it 'returns false for invalid date format' do
        actions = [{ timestamp: 'invalid date' }]
        expect(described_class.valid_dates?(actions)).to be false
      end

      it 'returns false for nil timestamp' do
        actions = [{ timestamp: nil }]
        expect(described_class.valid_dates?(actions)).to be false
      end

      it 'returns false for missing timestamp key' do
        actions = [{}]
        expect(described_class.valid_dates?(actions)).to be false
      end
    end
  end
end
