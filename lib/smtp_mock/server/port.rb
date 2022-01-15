# frozen_string_literal: true

module SmtpMock
  class Server
    class Port
      require 'socket'

      LOCALHOST = '127.0.0.1'
      RANDOM_FREE_PORT = 0

      class << self
        def random_free_port
          server = ::TCPServer.new(SmtpMock::Server::Port::LOCALHOST, SmtpMock::Server::Port::RANDOM_FREE_PORT)
          port = server.addr[1]
          server.close
          port
        end

        def port_open?(port)
          !::TCPSocket.new(SmtpMock::Server::Port::LOCALHOST, port).close
        rescue ::Errno::ECONNREFUSED, ::Errno::EHOSTUNREACH
          false
        end
      end
    end
  end
end
