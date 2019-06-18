require "hashie"
require "open3"

require "scallop/version"

class Scallop
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

  class Result < Hashie::Dash
    property :stdout
    property :stderr
    property :status

    def self.from_capture3(result)
      stdout, stderr, status = result
      new(stdout: stdout, stderr: stderr, status: status)
    end

    def success?
      status.success?
    end

    # stdout & stderr combined
    def output
      @_output ||= [stdout, stderr].reject { |s| s.nil? || s.empty? }.join("\n")
    end
  end

  class << self
    DSL_METHODS = %i{ cmd run run! sudo }

    DSL_METHODS.each do |method|
      define_method(method) do |*args|
        new.public_send(method, *args)
      end
    end
  end

  def sudo(sudo = true)
    @sudo = sudo
    self
  end

  def cmd(*cmd)
    @cmd =
      [*cmd]
        .map(&:to_s)
        .map(&Shellwords.method(:escape))
        .join(" ")

    self
  end

  def to_command
    raise ValidationFailed.new("cmd missing") if @cmd.nil?

    prefix =
      case @sudo
      when true then "sudo"
      when String, Symbol then "sudo -u #{@sudo}"
      else nil
      end

    [prefix, @cmd].compact.join(" ")
  end

  def run
    to_command
      .yield_self(&Open3.method(:capture3))
      .yield_self(&Result.method(:from_capture3))
  end

  def run!
    run.tap do |result|
      raise Errors::CommandFailed.new(result.stderr, result) unless result.success?
    end
  end
end
