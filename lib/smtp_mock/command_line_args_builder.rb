# frozen_string_literal: true

module SmtpMock
  require 'dry/struct'

  Types = ::Class.new { include Dry.Types }

  class CommandLineArgsBuilder < Dry::Struct
    IP_ADDRESS_PATTERN = /\A((1\d|[1-9]|2[0-4])?\d|25[0-5])(\.\g<1>){3}\z/.freeze
    PERMITTED_ATTRS = {
      SmtpMock::Types::Array.constrained(min_size: 1) => %i[
        blacklisted_helo_domains
        blacklisted_mailfrom_emails
        blacklisted_rcptto_emails
        not_registered_emails
      ].freeze,
      SmtpMock::Types::Bool.constrained(eql: true) => %i[log fail_fast multiple_rcptto multiple_message_receiving].freeze,
      SmtpMock::Types::Integer.constrained(gteq: 1) => %i[
        port
        session_timeout
        shutdown_timeout
        response_delay_helo
        response_delay_mailfrom
        response_delay_rcptto
        response_delay_data
        response_delay_message
        response_delay_rset
        response_delay_quit
        msg_size_limit
      ].freeze,
      SmtpMock::Types::String => %i[
        msg_greeting
        msg_invalid_cmd
        msg_invalid_cmd_helo_sequence
        msg_invalid_cmd_helo_arg
        msg_helo_blacklisted_domain
        msg_helo_received
        msg_invalid_cmd_mailfrom_sequence
        msg_invalid_cmd_mailfrom_arg
        msg_mailfrom_blacklisted_email
        msg_mailfrom_received
        msg_invalid_cmd_rcptto_sequence
        msg_invalid_cmd_rcptto_arg
        msg_rcptto_not_registered_email
        msg_rcptto_blacklisted_email
        msg_rcptto_received
        msg_invalid_cmd_data_sequence
        msg_data_received
        msg_msg_size_is_too_big
        msg_msg_received
        msg_invalid_cmd_rset_sequence
        msg_invalid_cmd_rset_arg
        msg_rset_received
        msg_quit_cmd
      ].freeze
    }.freeze

    class << self
      def call(**options)
        new(options).to_command_line_args_string
      rescue Dry::Struct::Error => error
        raise SmtpMock::Error::Argument, error.message
      end

      private

      def define_attribute
        ->((type, attributes)) { attributes.each { |field| attribute?(field, type) } }
      end
    end

    schema(schema.strict)

    attribute?(:host, SmtpMock::Types::String.constrained(format: SmtpMock::CommandLineArgsBuilder::IP_ADDRESS_PATTERN))
    SmtpMock::CommandLineArgsBuilder::PERMITTED_ATTRS.each(&define_attribute)

    def to_command_line_args_string
      to_h.map do |key, value|
        key = to_camel_case(key)
        value = format_by_type(value)
        value ? "-#{key}=#{value}" : "-#{key}"
      end.sort.join(' ')
    end

    private

    def to_camel_case(symbol)
      symbol.to_s.gsub(/_(\D)/) { ::Regexp.last_match(1).upcase }
    end

    def to_quoted(string)
      "\"#{string}\""
    end

    def format_by_type(object)
      case object
      when ::Array then to_quoted(object.join(','))
      when ::String then to_quoted(object)
      when ::TrueClass then nil
      else object
      end
    end
  end
end
