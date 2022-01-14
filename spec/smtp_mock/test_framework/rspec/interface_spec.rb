# frozen_string_literal: true

require_relative '../../../../lib/smtp_mock/test_framework/rspec/interface'

RSpec.describe SmtpMock::TestFramework::RSpec::Interface do
  after { described_class.clear_server! }

  describe '.start_server' do
    let(:smtp_mock_server_instance) { instance_double('SmtpMockServerInstance') }

    context 'with kwargs' do
      subject(:start_server) { described_class.start_server(**options) }

      let(:host) { random_ip_v4_address }
      let(:port) { random_port_number }
      let(:options) { { host: host, port: port } }

      it do
        expect(SmtpMock).to receive(:start_server).with(**options).and_return(smtp_mock_server_instance)
        expect(start_server).to eq(smtp_mock_server_instance)
      end
    end

    context 'without kwargs' do
      subject(:start_server) { described_class.start_server }

      it do
        expect(SmtpMock).to receive(:start_server).and_return(smtp_mock_server_instance)
        expect(start_server).to eq(smtp_mock_server_instance)
      end
    end
  end

  describe '.stop_server!' do
    subject(:stop_server) { described_class.stop_server! }

    let(:smtp_mock_server_instance) { instance_double('SmtpMockServerInstance', stop!: true) }

    context 'when smtp mock server exists' do
      before do
        allow(SmtpMock).to receive(:start_server).and_return(smtp_mock_server_instance)
        described_class.start_server
      end

      it { is_expected.to be(true) }
    end

    context 'when smtp mock server not exists' do
      it { is_expected.to be_nil }
    end
  end

  describe 'clear_server!' do
    subject(:clear_server) { described_class.clear_server! }

    it { is_expected.to be_nil }
  end
end
