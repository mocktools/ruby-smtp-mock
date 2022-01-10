# frozen_string_literal: true

RSpec.describe SmtpMock::ServerHelper, type: :helper do # rubocop:disable RSpec/FilePath
  describe '#cmd_lsof_port_by_pid' do
    let(:pid) { random_pid }

    it 'returns builded lsof command' do
      expect(cmd_lsof_port_by_pid(pid)).to eq("lsof -aPi -p #{pid}")
    end
  end
end
