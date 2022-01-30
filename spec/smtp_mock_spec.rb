# frozen_string_literal: true

RSpec.describe SmtpMock do
  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:SMTPMOCK_MIN_VERSION) }
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

    let(:total_active_servers) { 2 }
    let(:smtp_mock_server_instances) { create_fake_servers(active: total_active_servers, inactive: 5) }

    it do
      expect(::ObjectSpace).to receive(:each_object).with(described_class::Server).and_return(smtp_mock_server_instances)
      expect(running_servers.size).to eq(total_active_servers)
    end
  end

  describe '.stop_running_servers!' do
    subject(:stop_running_servers) { described_class.stop_running_servers! }

    before { allow(described_class).to receive(:running_servers).and_return(smtp_mock_server_instances) }

    context 'when servers not found' do
      let(:smtp_mock_server_instances) { [] }

      it { is_expected.to be(true) }
    end

    context 'when servers found' do
      let(:smtp_mock_server_instances) { create_fake_servers(active: 2, inactive: 0) }

      it { is_expected.to be(true) }
    end
  end

  describe 'SMTP mock server integration tests' do
    let(:host) { '127.0.0.1' }
    let(:helo_domain) { random_hostname }
    let(:mailfrom) { random_email }
    let(:rcptto) { random_email }

    context 'when successful scenario' do
      let(:expected_response_status) { 250 }
      let(:expected_response_message) { "#{expected_response_status} #{random_message}" }
      let(:smtp_mock_server_options) do
        {
          host: host,
          msg_msg_received: expected_response_message
        }
      end

      it 'SMTP client receives predefined values by SMTP mock server' do
        smtp_mock_server = described_class.start_server(**smtp_mock_server_options)
        smtp_response = smtp_request(
          host: host,
          port: smtp_mock_server.port,
          helo_domain: helo_domain,
          mailfrom: mailfrom,
          rcptto: rcptto,
          message: random_message
        )

        expect(smtp_response).to be_success
        expect(smtp_response).to have_status(expected_response_status)
        expect(smtp_response).to have_message_context(expected_response_message)

        smtp_mock_server.stop!
      end
    end

    context 'when failure scenario' do
      let(:expected_response_status) { 550 }
      let(:expected_response_message) { "#{expected_response_status} #{random_message}" }
      let(:smtp_mock_server_options) do
        {
          host: host,
          not_registered_emails: [rcptto],
          msg_rcptto_not_registered_email: expected_response_message
        }
      end

      it 'SMTP client raises exeption with expected error context' do
        smtp_mock_server = described_class.start_server(**smtp_mock_server_options)

        expect do
          smtp_request(
            host: host,
            port: smtp_mock_server.port,
            helo_domain: helo_domain,
            mailfrom: mailfrom,
            rcptto: rcptto,
            message: random_message
          )
        end.to raise_error(SmtpMock::ClientHelper::SmtpClient::Error, expected_response_message)

        smtp_mock_server.stop!
      end
    end
  end
end
