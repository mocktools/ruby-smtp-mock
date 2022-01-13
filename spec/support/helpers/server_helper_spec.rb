# frozen_string_literal: true

RSpec.describe SmtpMock::ServerHelper, type: :helper do # rubocop:disable RSpec/FilePath
  describe '#start_random_server' do
    let(:server_instance) { instance_double('SmtpMockServer') }

    context 'without total option' do
      it 'returns random running smtp mock server' do
        expect(SmtpMock).to receive(:start_server).and_return(server_instance)
        expect(start_random_server).to eq(server_instance)
      end
    end

    context 'with total option' do
      let(:total) { ::Random.rand(2..10) }

      it 'returns array with predefined count of smtp server instances' do
        expect(SmtpMock).to receive(:start_server).at_least(total).and_return(server_instance)
        expect(start_random_server(total: total)).to eq(::Array.new(total) { server_instance })
      end
    end
  end

  describe '#stop_all_running_servers' do
    it 'kills all running smtp mock servers' do
      expect(SmtpMock).to receive(:stop_running_servers!)
      stop_all_running_servers
    end
  end
end
