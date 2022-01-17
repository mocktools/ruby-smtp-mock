# frozen_string_literal: true

RSpec.describe SmtpMock::Server::Port do
  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:LOCALHOST) }
    it { expect(described_class).to be_const_defined(:RANDOM_FREE_PORT) }
  end

  describe '.random_free_port' do
    subject(:random_free_port) { described_class.random_free_port }

    it 'return random free port number' do
      expect(random_free_port).to be_an_instance_of(::Integer)
      expect(described_class.port_open?(random_free_port)).to be(false)
    end
  end

  describe '.port_open?' do
    subject(:port_open?) { described_class.port_open?(port) }

    let(:port) { random_port_number }
    let(:tcp_socket_instance) { instance_double('TcpSocketInstance', close: nil) }

    context 'when port is opened' do
      it do
        expect(::TCPSocket)
          .to receive(:new)
          .with(SmtpMock::Server::Port::LOCALHOST, port)
          .and_return(tcp_socket_instance)
        expect(port_open?).to be(true)
      end
    end

    context 'when port is closed' do
      [::Errno::ECONNREFUSED, ::Errno::EHOSTUNREACH].each do |error|
        it do
          expect(::TCPSocket)
            .to receive(:new)
            .with(SmtpMock::Server::Port::LOCALHOST, port)
            .and_raise(error)
          expect(port_open?).to be(false)
        end
      end
    end
  end
end
