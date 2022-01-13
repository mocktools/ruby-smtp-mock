# frozen_string_literal: true

module SmtpMock
  module DependencyHelper
    def cmd_lsof_port_by_pid(pid)
      "lsof -aPi -p #{pid}"
    end

    def lsof_port_by_pid_result(port = nil)
      ":#{port || random_port} (LISTEN)"
    end

    def compose_command(command_line_args)
      SmtpMock::Dependency.compose_command(command_line_args)
    end
  end
end
