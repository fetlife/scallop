# frozen_string_literal: true

module Scallop
  class Result
    attr_reader :stdout
    attr_reader :stderr
    attr_reader :status
    attr_reader :timing
    attr_reader :output

    def initialize(stdout:, stderr:, status:, timing:)
      @stdout = stdout
      @stderr = stderr
      @status = status
      @timing = timing
      @output = [stdout, stderr].reject { |s| s.nil? || s.empty? }.join("\n")
    end

    def success?
      @status.success?
    end
  end
end
