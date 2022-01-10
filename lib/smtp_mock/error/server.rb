# frozen_string_literal: true

module SmtpMock
  module Error
    class Server < ::RuntimeError
      ERROR_MESSAGE = 'smtpmock server cannot be started, for details please checkout your stdout log'

      def initialize
        super(SmtpMock::Error::Server::ERROR_MESSAGE)
      end
    end
  end
end
