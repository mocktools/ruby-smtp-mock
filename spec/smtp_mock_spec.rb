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
      let(:options) { { port: random_port } }

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

  # TODO: add integration tests
  # describe 'SMTP mock server integration tests' do
  # end
end
