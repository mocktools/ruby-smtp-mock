# frozen_string_literal: true

module SmtpMock
  module ServerHelper
    def cmd_lsof_port_by_pid(pid)
      "lsof -aPi -p #{pid}"
    end
  end
end
