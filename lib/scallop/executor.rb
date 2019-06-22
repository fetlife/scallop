module Scallop
  module Executor
    def self.run(command)
      capture3, timing = measure do
        Open3.capture3(command)
      end
      build_result(capture3, timing)
    end

    def self.run!(command)
      run(command).tap do |result|
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
          stdout: stdout.strip,
          stderr: stderr.strip,
          status: status,
          timing: timing,
        )
        .freeze
    end
  end
end
