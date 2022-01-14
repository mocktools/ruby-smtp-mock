# frozen_string_literal: true

module SmtpMock
  module ClientHelper
    class SmtpClient
      require 'net/smtp'

      UNDEFINED_VERSION = '0.0.0'

      Error = ::Class.new(::StandardError)

      def initialize(host, port, net_class = ::Net::SMTP)
        @net_class = net_class
        @net_smtp_version = resolve_net_smtp_version
        @net_smtp = old_net_smtp? ? net_class.new(host, port) : net_class.new(host, port, tls_verify: false)
      end

      def start(helo_domain, &block)
        return net_smtp.start(helo_domain, &block) if net_smtp_version < '0.2.0'
        return net_smtp.start(helo_domain, tls_verify: false, &block) if old_net_smtp?
        net_smtp.start(helo: helo_domain, &block)
      end

      private

      attr_reader :net_class, :net_smtp_version, :net_smtp

      def resolve_net_smtp_version
        return net_class::VERSION if net_class.const_defined?(:VERSION)
        SmtpMock::ClientHelper::SmtpClient::UNDEFINED_VERSION
      end

      def old_net_smtp?
        net_smtp_version < '0.3.0'
      end
    end

    def smtp_request(host:, port:, mailfrom:, rcptto:, message:, helo_domain: nil) # rubocop:disable Metrics/ParameterLists
      SmtpMock::ClientHelper::SmtpClient.new(host, port).start(helo_domain) do |session|
        session.send_message(message, mailfrom, rcptto)
      rescue ::Net::SMTPFatalError => error
        raise SmtpMock::ClientHelper::SmtpClient::Error, error.message
      end
    end
  end
end
