# frozen_string_literal: true

require_relative '../../../../lib/smtp_mock/test_framework/rspec/helper'

class TestClass
  include SmtpMock::TestFramework::RSpec::Helper
end

RSpec.describe SmtpMock::TestFramework::RSpec::Helper do
  let(:test_class_instance) { TestClass.new }

  describe '.smtp_mock_server' do
    let(:smtp_mock_server_instance) { instance_double('SmtpMockServerInstance') }

    context 'with kwargs' do
      subject(:helper) { test_class_instance.smtp_mock_server(**options) }

      let(:host) { random_ip_v4_address }
      let(:port) { random_port_number }
      let(:options) { { host: host, port: port } }

      it do
        expect(SmtpMock::TestFramework::RSpec::Interface)
          .to receive(:start_server)
          .with(**options)
          .and_return(smtp_mock_server_instance)
        expect(helper).to eq(smtp_mock_server_instance)
      end
    end

    context 'without kwargs' do
      subject(:helper) { test_class_instance.smtp_mock_server }

      it do
        expect(SmtpMock::TestFramework::RSpec::Interface)
          .to receive(:start_server)
          .and_return(smtp_mock_server_instance)
        expect(helper).to eq(smtp_mock_server_instance)
      end
    end
  end
end
