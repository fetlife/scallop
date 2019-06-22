# frozen_string_literal: true

# :nodoc:
module Scallop
  # Adds ergonomic public API methods.
  module PublicAPI
    METHODS = %i[cmd sudo].freeze

    def self.included(base)
      base.extend ClassMethods
    end

    # :nodoc:
    module ClassMethods
      METHODS.each do |method|
        define_method(method) do |*args|
          CommandBuilder.new.public_send(method, *args)
        end
      end
    end
  end

  include PublicAPI
end
