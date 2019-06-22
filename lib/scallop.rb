require "benchmark"
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
    property :stdout, required: true
    property :stderr, required: true
    property :status, required: true
    property :timing

    def self.from_capture3_and_timing(result, timing)
      from_capture3(result).merge(timing: timing)
    end

    def self.from_capture3(result)
      stdout, stderr, status = result
      new(stdout: stdout.strip, stderr: stderr.strip, status: status)
    end

    def success?
      status.success?
    end

    # stdout & stderr combined
    def output
      @_output ||= [stdout, stderr].reject { |s| s.nil? || s.empty? }.join("\n")
    end
  end

  class Param < Hashie::Dash
    property :key, required: true
  end

  class << self
    DSL_METHODS = %i{ cmd run run! sudo }

    DSL_METHODS.each do |method|
      define_method(method) do |*args|
        new.public_send(method, *args)
      end
    end

    def param(key)
      Param.new(key: key)
    end
  end

  def initialize
    @params = {}
    @cmd = []
  end

  def sudo(sudo = true)
    dup
      .tap do |instance|
        instance.instance_eval { @sudo = sudo }
      end
      .freeze
  end

  def cmd(*cmd)
    dup
      .tap do |instance|
        instance.instance_eval { @cmd += cmd }
      end
      .freeze
  end

  def set(params)
    new_params = @params.merge(params)

    dup
      .tap do |instance|
        instance.instance_eval { @params = new_params }
      end
      .freeze
  end

  def to_command
    raise Errors::ValidationFailed.new("cmd missing") if @cmd.empty?

    prefix =
      case @sudo
      when true then "sudo"
      when String, Symbol then "sudo -u #{@sudo}"
      else nil
      end

    cmd =
      [*@cmd]
        .flatten
        .map do |cmd_part|
          case cmd_part
          when Param
            @params[cmd_part.key]
              .tap do |value|
                raise Errors::ValidationFailed.new("value for param '#{cmd_part.key}' not set") if value.nil?
              end
              .yield_self(&Shellwords.method(:escape))
          when :|
            cmd_part
          else
            cmd_part.to_s.yield_self(&Shellwords.method(:escape))
          end
        end
        .join(" ")

    [prefix, cmd].compact.join(" ")
  end

  def run
    to_command
      .yield_self do |command|
        measure do
          Open3.capture3(command)
        end
      end
      .yield_self do |capture3, timing|
        Result.from_capture3_and_timing(capture3, timing)
      end
  end

  def measure
    result = nil
    timing = Benchmark.measure { result = yield }
    [result, timing]
  end

  def run!
    run.tap do |result|
      raise Errors::CommandFailed.new(result.stderr, result) unless result.success?
    end
  end

  def get_cmd
    @cmd
  end

  def |(other)
    cmd(:|, other.get_cmd)
  end
end
