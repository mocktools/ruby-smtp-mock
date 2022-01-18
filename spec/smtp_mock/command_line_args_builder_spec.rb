# frozen_string_literal: true

RSpec.describe SmtpMock::CommandLineArgsBuilder do
  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:IP_ADDRESS_PATTERN) }
    it { expect(described_class).to be_const_defined(:PERMITTED_ATTRS) }
  end

  describe '.call' do
    subject(:command_line_args_builder) { described_class.call(**options) }

    describe 'Success' do
      context 'when permitted command line arguments with valid values passed' do
        let(:host) { random_ip_v4_address }
        let(:port) { rand(2525..3535) }
        let(:session_timeout) { rand(10..20) }
        let(:shutdown_timeout) { rand(30..40) }
        let(:msg_size_limit) { rand(10_000..20_000) }
        let(:blacklisted_helo_domains) { ::Array.new(2) { random_hostname } }
        let(:blacklisted_mailfrom_emails) { ::Array.new(2) { random_email } }
        let(:blacklisted_rcptto_emails) { ::Array.new(2) { random_email } }
        let(:not_registered_emails) { ::Array.new(2) { random_email } }
        let(:string_args) do
          %i[
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
            msg_quit_cmd
          ].zip('a'..'z').to_h
        end
        let(:options) do
          {
            host: host,
            port: port,
            log: true,
            session_timeout: session_timeout,
            shutdown_timeout: shutdown_timeout,
            fail_fast: true,
            msg_size_limit: msg_size_limit,
            blacklisted_helo_domains: blacklisted_helo_domains,
            blacklisted_mailfrom_emails: blacklisted_mailfrom_emails,
            blacklisted_rcptto_emails: blacklisted_rcptto_emails,
            not_registered_emails: not_registered_emails,
            **string_args
          }
        end
        let(:builded_command_line_args_string) do
          %(-blacklistedHeloDomains="#{blacklisted_helo_domains.join(',')}"
-blacklistedMailfromEmails="#{blacklisted_mailfrom_emails.join(',')}"
-blacklistedRcpttoEmails="#{blacklisted_rcptto_emails.join(',')}"
-failFast
-host="#{host}"
-log
-msgDataReceived="q"
-msgGreeting="a"
-msgHeloBlacklistedDomain="e"
-msgHeloReceived="f"
-msgInvalidCmd="b"
-msgInvalidCmdDataSequence="p"
-msgInvalidCmdHeloArg="d"
-msgInvalidCmdHeloSequence="c"
-msgInvalidCmdMailfromArg="h"
-msgInvalidCmdMailfromSequence="g"
-msgInvalidCmdRcpttoArg="l"
-msgInvalidCmdRcpttoSequence="k"
-msgMailfromBlacklistedEmail="i"
-msgMailfromReceived="j"
-msgMsgReceived="s"
-msgMsgSizeIsTooBig="r"
-msgQuitCmd="t"
-msgRcpttoBlacklistedEmail="n"
-msgRcpttoNotRegisteredEmail="m"
-msgRcpttoReceived="o"
-msgSizeLimit=#{msg_size_limit}
-notRegisteredEmails="#{not_registered_emails.join(',')}"
-port=#{port}
-sessionTimeout=#{session_timeout}
-shutdownTimeout=#{shutdown_timeout})
        end

        it 'returns string with builded command line arguments' do
          expect(command_line_args_builder).to eq(builded_command_line_args_string.tr("\n", ' '))
        end
      end
    end

    describe 'Failure' do
      shared_examples 'invalid command line argument' do
        it do
          expect { command_line_args_builder }.to raise_error(SmtpMock::Error::Argument)
        end
      end

      context 'when not permitted command line arguments passed' do
        let(:options) { { not_permitted_arg_1: 42, not_permitted_arg_2: 43 } }

        it_behaves_like 'invalid command line argument'
      end

      [42, 'not_ip_address', '255.255.255.256'].each do |value|
        context 'when invalid host command line argument value passed' do
          let(:options) { { host: value } }

          it_behaves_like 'invalid command line argument'
        end
      end

      described_class::PERMITTED_ATTRS[SmtpMock::Types::Array.constrained(min_size: 1)]
        .product([42, []]).each do |key, value|
          context 'when invalid value for array command line argument type passed' do
            let(:options) { { key => value } }

            it_behaves_like 'invalid command line argument'
          end
        end

      described_class::PERMITTED_ATTRS[SmtpMock::Types::Bool.constrained(eql: true)]
        .product([42, false]).each do |key, value|
          context 'when invalid value for boolean command line argument type passed' do
            let(:options) { { key => value } }

            it_behaves_like 'invalid command line argument'
          end
        end

      described_class::PERMITTED_ATTRS[SmtpMock::Types::Integer.constrained(gteq: 1)]
        .product(['42', -42]).each do |key, value|
          context 'when invalid value for integer command line argument type passed' do
            let(:options) { { key => value } }

            it_behaves_like 'invalid command line argument'
          end
        end

      described_class::PERMITTED_ATTRS[SmtpMock::Types::String]
        .product([42]).each do |key, value|
          context 'when invalid value for integer command line argument type passed' do
            let(:options) { { key => value } }

            it_behaves_like 'invalid command line argument'
          end
        end
    end
  end
end
