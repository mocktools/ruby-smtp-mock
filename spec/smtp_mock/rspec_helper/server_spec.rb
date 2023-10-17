# frozen_string_literal: true

RSpec.describe SmtpMock::RspecHelper::Server, type: :helper do
  describe '#create_fake_servers' do
    subject(:fake_servers) { create_fake_servers(**options) }

    context 'when active 1, inactive 0' do
      let(:options) { { inactive: 0 } }

      it 'returns array with one active fake server' do
        expect(fake_servers.size).to eq(1)
        server = fake_servers.first
        expect(server.active?).to be(true)
        expect(server.stop!).to be(true)
      end
    end

    context 'when active 0, inactive 0' do
      let(:options) { { active: 0, inactive: 0 } }

      it 'returns empty array' do
        expect(fake_servers).to be_empty
      end
    end

    context 'when active 0, inactive 1' do
      let(:options) { { active: 0 } }

      it 'returns array with one active fake server' do
        expect(fake_servers.size).to eq(1)
        server = fake_servers.first
        expect(server.active?).to be_nil
        expect(server.stop!).to be_nil
      end
    end
  end

  describe '#reset_err_log' do
    it 'resets err_log instance variable' do
      expect(SmtpMock::Server::Process).to receive(:instance_variable_set).with(:@err_log, nil)
      reset_err_log
    end
  end
end
