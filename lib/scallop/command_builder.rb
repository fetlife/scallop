module Scallop
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

    def get_cmd
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
      cmd(:|, other.get_cmd)
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
              value = @params[cmd_part.key]
              raise Errors::ValidationFailed.new("value for param '#{cmd_part.key}' not set") if value.nil?
              Shellwords.escape(value.to_s)
            when :|
              cmd_part
            else
              Shellwords.escape(cmd_part.to_s)
            end
          end
          .join(" ")

      [prefix, cmd].compact.join(" ")
    end

    def run
      Executor.run(to_command)
    end

    def run!
      Executor.run!(to_command)
    end
  end
end
