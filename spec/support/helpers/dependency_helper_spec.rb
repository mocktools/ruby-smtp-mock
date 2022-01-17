# frozen_string_literal: true

RSpec.describe SmtpMock::DependencyHelper, type: :helper do # rubocop:disable RSpec/FilePath
  describe '#compose_command' do
    let(:command_line_args) { '-a -b 42' }

    it 'returns composed command' do
      expect(SmtpMock::Dependency).to receive(:compose_command).with(command_line_args).and_call_original
      compose_command(command_line_args)
    end
  end
end
