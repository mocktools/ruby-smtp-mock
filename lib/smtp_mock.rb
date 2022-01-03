# frozen_string_literal: true

require_relative 'smtp_mock/core'

module SmtpMock
  # class << self
  #   def start_server(server = SmtpMock::Server, **options)
  #     server.new(**options)
  #   end

  #   def running_servers
  #     ::ObjectSpace.each_object(SmtpMock::Server).select(&:active?)
  #   end

  #   def stop_running_servers!
  #     running_servers.all?(&:stop!)
  #   end
  # end
end
