module Scallop
  module Errors
    class CommandFailed < StandardError
      attr_reader :result

      def initialize(message, result)
        @result = result
        super(message)
      end
    end

    class ValidationFailed < StandardError
    end
  end
end
