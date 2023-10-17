# frozen_string_literal: true

RSpec.describe SmtpMock::RspecHelper::Client::SmtpClient, type: :helper do
  subject(:smtp_client_instance) { described_class.new(host, port, net_class) }

  let(:host) { random_hostname }
  let(:port) { random_port_number }
  let(:net_smtp_instance) { instance_double('NetSmtpInstance') }
  let(:net_class) { class_double('NetClass') }

  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:UNDEFINED_VERSION) }
    it { expect(described_class::Error).to be < ::StandardError }
  end

  describe '.new' do
    context 'when out of the box Net::SMTP version' do
      it 'creates session instance with net smtp instance inside' do
        expect(net_class).to receive(:new).with(host, port).and_return(net_smtp_instance)
        smtp_client_instance
      end
    end

    context 'when Net::SMTP version < 0.3.0' do
      before { net_class.send(:const_set, :VERSION, '0.2.128506') }

      it 'creates session instance with net smtp instance inside' do
        expect(net_class).to receive(:new).with(host, port).and_return(net_smtp_instance)
        smtp_client_instance
      end
    end

    context 'when Net::SMTP version >= 0.3.0' do
      before { net_class.send(:const_set, :VERSION, '0.3.0') }

      it 'creates session instance with net smtp instance inside' do
        expect(net_class).to receive(:new).with(host, port, tls_verify: false)
        smtp_client_instance
      end
    end
  end

  describe '#start' do
    subject(:session_start) { smtp_client_instance.start(helo_domain, &session_actions) }

    let(:helo_domain) { random_hostname }
    let(:session_actions) { proc {} }

    context 'when out of the box Net::SMTP version' do
      before { allow(net_class).to receive(:new).with(host, port).and_return(net_smtp_instance) }

      it 'passes helo domain as position argument' do
        expect(net_smtp_instance).to receive(:start).with(helo_domain, &session_actions)
        session_start
      end
    end

    context 'when Net::SMTP version in range 0.1.0...0.2.0' do
      before do
        net_class.send(:const_set, :VERSION, '0.1.314')
        allow(net_class).to receive(:new).with(host, port).and_return(net_smtp_instance)
      end

      it 'passes helo domain as position argument' do
        expect(net_smtp_instance).to receive(:start).with(helo_domain, &session_actions)
        session_start
      end
    end

    context 'when Net::SMTP version in range 0.2.0...0.3.0' do
      before do
        net_class.send(:const_set, :VERSION, '0.2.128506')
        allow(net_class).to receive(:new).with(host, port).and_return(net_smtp_instance)
      end

      it 'passes helo domain as position argument' do
        expect(net_smtp_instance).to receive(:start).with(helo_domain, tls_verify: false, &session_actions)
        session_start
      end
    end

    context 'when Net::SMTP version >= 0.3.0' do
      before do
        net_class.send(:const_set, :VERSION, '0.3.0')
        allow(net_class).to receive(:new).with(host, port, tls_verify: false).and_return(net_smtp_instance)
      end

      it 'passes helo domain as keyword argument' do
        expect(net_smtp_instance).to receive(:start).with(helo: helo_domain, &session_actions)
        session_start
      end
    end
  end
end
