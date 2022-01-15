# frozen_string_literal: true

RSpec.describe SmtpMock do
  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:Types) }
  end

  describe '.start_server' do
    subject(:smtp_mock_server) { described_class.start_server(server_class, **options) }

    let(:server_class) { class_double('SmtpMockServer') }

    context 'without keyword args' do
      let(:options) { {} }

      it 'creates and runs SMTP mock server instance with default settings' do
        expect(server_class).to receive(:new)
        smtp_mock_server
      end
    end

    context 'with keyword args' do
      let(:options) { { host: random_ip_v4_address, port: random_port_number } }

      it 'creates and runs SMTP mock server instance with custom settings' do
        expect(server_class).to receive(:new).with(**options)
        smtp_mock_server
      end
    end
  end

  describe '.running_servers' do
    subject(:running_servers) { described_class.running_servers }

    context 'when servers not found' do
      it 'returns empty list of running servers' do
        expect(running_servers).to be_an_instance_of(::Array)
        expect(running_servers).to be_empty
      end
    end

    context 'when servers found' do
      let(:servers_count) { 2 }

      before { start_random_server(total: servers_count) }

      after { stop_all_running_servers }

      it 'returns list of running servers' do
        expect(running_servers).to be_an_instance_of(::Array)
        expect(running_servers.size).to eq(servers_count)
      end
    end
  end

  describe '.stop_running_servers!' do
    subject(:stop_running_servers) { described_class.stop_running_servers! }

    context 'when servers not found' do
      it { is_expected.to be(true) }
    end

    context 'when servers found' do
      before { start_random_server(total: 2) }

      it { is_expected.to be(true) }
    end
  end

  # TODO: different behaviour on local and CI envs. Research needed
  # describe 'SMTP mock server integration tests' do
  #   let(:host) { '127.0.0.1' }
  #   let(:helo_domain) { random_hostname }
  #   let(:mailfrom) { random_email }
  #   let(:rcptto) { random_email }

  #   context 'when successful scenario' do
  #     let(:expected_response_status) { 250 }
  #     let(:expected_response_message) { "#{expected_response_status} #{random_message}" }
  #     let(:smtp_mock_server_options) do
  #       {
  #         host: host,
  #         msg_msg_received: expected_response_message
  #       }
  #     end

  #     it 'SMTP client receives predefined values by SMTP mock server' do
  #       smtp_mock_server = described_class.start_server(**smtp_mock_server_options)
  #       smtp_response = smtp_request(
  #         host: host,
  #         port: smtp_mock_server.port,
  #         helo_domain: helo_domain,
  #         mailfrom: mailfrom,
  #         rcptto: rcptto,
  #         message: random_message
  #       )

  #       expect(smtp_response).to be_success
  #       expect(smtp_response).to have_status(expected_response_status)
  #       expect(smtp_response).to have_message_context(expected_response_message)

  #       smtp_mock_server.stop!
  #     end
  #   end

  #   context 'when failure scenario' do
  #     let(:expected_response_status) { 550 }
  #     let(:expected_response_message) { "#{expected_response_status} #{random_message}" }
  #     let(:smtp_mock_server_options) do
  #       {
  #         host: host,
  #         not_registered_emails: [rcptto],
  #         msg_rcptto_not_registered_email: expected_response_message
  #       }
  #     end

  #     it 'SMTP client raises exeption with expected error context' do
  #       smtp_mock_server = described_class.start_server(**smtp_mock_server_options)

  #       expect do
  #         smtp_request(
  #           host: host,
  #           port: smtp_mock_server.port,
  #           helo_domain: helo_domain,
  #           mailfrom: mailfrom,
  #           rcptto: rcptto,
  #           message: random_message
  #         )
  #       end.to raise_error(SmtpMock::ClientHelper::SmtpClient::Error, "#{expected_response_message}\n")

  #       smtp_mock_server.stop!
  #     end
  #   end
  # end
end
