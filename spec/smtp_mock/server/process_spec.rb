# frozen_string_literal: true

RSpec.describe SmtpMock::Server::Process do
  let(:pid) { random_pid }

  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:SIGNULL) }
    it { expect(described_class).to be_const_defined(:SIGKILL) }
    it { expect(described_class).to be_const_defined(:SIGTERM) }
    it { expect(described_class).to be_const_defined(:TMP_LOG_PATH) }
    it { expect(described_class).to be_const_defined(:WARMUP_DELAY) }
  end

  describe '.create' do
    subject(:create_process) { described_class.create(command) }

    let(:command) { 'some_command -some_args' }
    let(:err_output) { described_class.send(:err_log) }

    before do
      reset_err_log
      stub_const('SmtpMock::Server::Process::TMP_LOG_PATH', err_output_path)
      allow(::Process).to receive(:spawn).with(command, err: err_output).and_return(pid)
      allow(::Kernel).to receive(:sleep).with(SmtpMock::Server::Process::WARMUP_DELAY)
    end

    after { reset_err_log }

    context 'when the error did not happen' do
      let(:err_output_path) { '../../../spec/support/fixtures/err_log_empty' }

      it 'creates background process, returns pid' do
        expect(create_process).to eq(pid)
      end
    end

    context 'when the error happened' do
      let(:err_output_path) { '../../../spec/support/fixtures/err_log_with_context' }

      it { expect { create_process }.to raise_error(SmtpMock::Error::Server, 'Some error context here') }
    end
  end

  describe '.alive?' do
    subject(:alive?) { described_class.alive?(pid) }

    context 'when existent pid' do
      it do
        expect(::Process).to receive(:kill).with(SmtpMock::Server::Process::SIGNULL, pid)
        expect(alive?).to be(true)
      end
    end

    context 'when non-existent pid' do
      it do
        expect(::Process).to receive(:kill).with(SmtpMock::Server::Process::SIGNULL, pid).and_raise(::Errno::ESRCH)
        expect(alive?).to be(false)
      end
    end
  end

  describe '.kill' do
    subject(:kill_process) { described_class.kill(signal_number, pid) }

    let(:signal_number) { random_signal }

    before { allow(::Process).to receive(:detach).with(pid) }

    context 'when existent pid' do
      it do
        expect(::Process).to receive(:kill).with(signal_number, pid)
        expect(kill_process).to be(true)
      end
    end

    context 'when non-existent pid' do
      it do
        expect(::Process).to receive(:kill).with(signal_number, pid).and_raise(::Errno::ESRCH)
        expect(kill_process).to be(false)
      end
    end
  end
end
