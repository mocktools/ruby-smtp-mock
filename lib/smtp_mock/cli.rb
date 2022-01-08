# frozen_string_literal: true

module SmtpMock
  module Cli
    Command = ::Struct.new(:install_path, :sudo, :success, :message) do
      include Resolver
    end

    def self.call(command_line_args, command = SmtpMock::Cli::Command)
      command.new.tap do |cmd|
        cmd.resolve(command_line_args)
        ::Kernel.puts(cmd.message)
        ::Kernel.exit(cmd.success ? 0 : 1)
      end
    end
  end
end
