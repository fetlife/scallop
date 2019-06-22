module Scallop
  class Param
    def self.[](key)
      new(key)
    end

    attr_reader :key

    def initialize(key)
      @key = key
    end
  end
end
