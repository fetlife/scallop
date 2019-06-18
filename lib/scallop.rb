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
        instance.instance_eval { @cmd = cmd }
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
    raise Errors::ValidationFailed.new("cmd missing") if @cmd.nil?

    prefix =
      case @sudo
      when true then "sudo"
      when String, Symbol then "sudo -u #{@sudo}"
      else nil
      end

    cmd =
      [*@cmd]
        .map do |cmd_part|
          case cmd_part
          when Param
            @params[cmd_part.key].tap do |value|
              raise Errors::ValidationFailed.new("value for param '#{cmd_part.key}' not set") if value.nil?
            end
          else
            cmd_part.to_s
          end
        end
        .map(&Shellwords.method(:escape))
        .join(" ")

    [prefix, cmd].compact.join(" ")
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
