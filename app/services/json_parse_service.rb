# frozen_string_literal: true

class JsonParseService
  def self.parse(object, keys)
    camelize_keys(filter_keys(object, keys))
  end

  def self.filter_keys(object, keys)
    object.slice(*keys.map(&:to_sym))
  end

  def self.camelize_keys(hash)
    hash.transform_keys { |key| key.to_s.camelize(:lower).to_sym }
  end
end
