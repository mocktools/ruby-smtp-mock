# frozen_string_literal: true

RSpec.describe SmtpMock::DependencyHelper, type: :helper do # rubocop:disable RSpec/FilePath
  describe '#cmd_lsof_port_by_pid' do
    let(:pid) { random_pid }

    it 'returns builded lsof command' do
      expect(cmd_lsof_port_by_pid(pid)).to eq("lsof -aPi -p #{pid}")
    end
  end

  describe '#lsof_port_by_pid_result' do
    context 'when port not specified' do
      it { expect(lsof_port_by_pid_result).to match(SmtpMock::Server::LSOF_USED_PORT_PATTERN) }
    end

    context 'when port specified' do
      let(:port) { random_port_number }

      it { expect(lsof_port_by_pid_result(port)).to eq(":#{port} (LISTEN)") }
    end
  end

  describe '#compose_command' do
    let(:command_line_args) { '-a -b 42' }

    it 'returns composed command' do
      expect(SmtpMock::Dependency).to receive(:compose_command).with(command_line_args).and_call_original
      compose_command(command_line_args)
    end
  end
end
