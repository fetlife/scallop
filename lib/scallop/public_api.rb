# frozen_string_literal: true

module Scallop
  module PublicAPI
    METHODS = %i[cmd sudo].freeze

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      METHODS.each do |method|
        define_method(method) do |*args|
          CommandBuilder.new.public_send(method, *args)
        end
      end
    end
  end
end
