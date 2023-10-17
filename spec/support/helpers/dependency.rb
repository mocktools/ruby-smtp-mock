# frozen_string_literal: true

module SmtpMock
  module RspecHelper
    module Dependency
      def compose_command(command_line_args)
        SmtpMock::Dependency.compose_command(command_line_args)
      end
    end
  end
end
