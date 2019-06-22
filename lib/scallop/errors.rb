# frozen_string_literal: true

module Scallop
  module Errors
    # Error representing command failure.
    class CommandFailed < StandardError
      attr_reader :result

      def initialize(message, result)
        @result = result
        super(message)
      end
    end

    # Error representing absense of required parameters or incorrect usage
    class ValidationFailed < StandardError
    end
  end
end
