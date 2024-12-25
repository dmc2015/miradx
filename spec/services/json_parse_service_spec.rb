# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JsonParseService do
  describe '.parse' do
    let(:object) { { snake_case_key: 'value', other_key: 123 } }
    let(:keys) { [:snake_case_key] }

    it 'returns object with camelized keys' do
      result = described_class.parse(object, keys)
      expect(result).to eq({ snakeCaseKey: 'value' })
    end
  end

  describe '.filter_keys' do
    let(:object) { { keep_this: 1, remove_this: 2 } }
    let(:keys) { [:keep_this] }

    it 'returns object with only specified keys' do
      result = described_class.filter_keys(object, keys)
      expect(result).to eq({ keep_this: 1 })
    end
  end

  describe '.camelize_keys' do
    let(:hash) { { snake_case_key: 1, another_key: 2 } }

    it 'returns hash with camelized keys' do
      result = described_class.camelize_keys(hash)
      expect(result).to eq({ snakeCaseKey: 1, anotherKey: 2 })
    end
  end
end
