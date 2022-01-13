# frozen_string_literal: true

module SmtpMock
  module ServerHelper
    def start_random_server(total: 1)
      servers = ::Array.new(total) { SmtpMock.start_server }
      total.eql?(1) ? servers.first : servers
    end

    def stop_all_running_servers
      SmtpMock.stop_running_servers!
    end
  end
end
