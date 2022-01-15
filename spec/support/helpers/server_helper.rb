# frozen_string_literal: true

module SmtpMock
  module ServerHelper
    def create_fake_servers(active: 1, inactive: 1)
      server = ::Struct.new(:active?, :stop!)
      active_servers = ::Array.new(active) { server.new(true, true) }
      inactive_servers = ::Array.new(inactive) { server.new }
      (active_servers + inactive_servers).shuffle
    end

    def reset_err_log
      SmtpMock::Server::Process.instance_variable_set(:@err_log, nil)
    end
  end
end
