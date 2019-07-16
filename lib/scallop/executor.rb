# frozen_string_literal: true

module Scallop
  # Executes command and returns result.
  module Executor
    def self.run(command, args = {})
      capture3, timing = measure do
        Open3.capture3(command, args)
      end
      build_result(capture3, timing)
    end

    def self.run!(command, args = {})
      run(command, args).tap do |result|
        raise Errors::CommandFailed.new(result.stderr, result) unless result.success?
      end
    end

    def self.measure
      result = nil
      timing = Benchmark.measure { result = yield }
      [result, timing]
    end

    def self.build_result(capture3, timing)
      stdout, stderr, status = capture3

      Result
        .new(
          stdout: stdout.to_s.strip,
          stderr: stderr.to_s.strip,
          status: status,
          timing: timing,
        )
        .freeze
    end
  end
end
