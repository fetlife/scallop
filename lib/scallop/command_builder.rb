# frozen_string_literal: true

module Scallop
  # Implements command building interface with immutability.
  class CommandBuilder
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

    def read_cmd
      @cmd
    end

    def set(params)
      new_params = @params.merge(params)

      dup
        .tap do |instance|
          instance.instance_eval { @params = new_params }
        end
        .freeze
    end

    def |(other)
      cmd(:|, other.read_cmd)
    end

    def run(args = {})
      Executor.run(to_command, args)
    end

    def run!
      Executor.run!(to_command)
    end

    def to_command
      raise Errors::ValidationFailed, 'cmd missing' if @cmd.empty?

      [build_prefix, build_command].compact.join(' ')
    end

    private

    def build_prefix
      case @sudo
      when true then 'sudo'
      when String, Symbol then "sudo -u #{@sudo}"
      end
    end

    def build_command
      [*@cmd]
        .flatten
        .map do |cmd_part|
          case cmd_part
          when Param
            value = @params[cmd_part.key]
            raise Errors::ValidationFailed, "value for param '#{cmd_part.key}' not set" if value.nil?

            Shellwords.escape(value.to_s)
          when :|
            cmd_part
          else
            Shellwords.escape(cmd_part.to_s)
          end
        end
        .join(' ')
    end
  end
end
