# frozen_string_literal: true

RSpec.describe SmtpMock::Server do
  let(:converted_command_line_args) { '-a -b 42' }
  let(:exec_result) { 'some exec result' }
  let(:pid) { random_pid }

  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:WARMUP_DELAY) }
    it { expect(described_class).to be_const_defined(:LSOF_USED_PORT_PATTERN) }
  end

  describe '.new' do
    describe 'Success' do
      subject(:server_instance) { described_class.new(deps_checker, args_builder, **args) }

      let(:deps_checker) { SmtpMock::Dependency }
      let(:args_builder) { class_double('CommandLineArgsBuilder') }

      before do
        allow(deps_checker).to receive(:verify_dependencies)
        allow(args_builder).to receive(:call).and_return(converted_command_line_args)
        allow(::Kernel).to receive(:sleep).with(SmtpMock::Server::WARMUP_DELAY)
      end

      context 'when port passed' do
        let(:port) { random_port }
        let(:args) { { port: port } }

        it 'creates and runs server instance, gets port from args' do
          expect(::Kernel).to receive(:exec).with(compose_command(converted_command_line_args)).and_return(exec_result)
          expect(::Kernel).to receive(:fork) { |&block| expect(block.call).to eq(exec_result) }.and_return(pid)
          expect(::Kernel).to receive(:`).with(cmd_lsof_port_by_pid(pid)).and_return(lsof_port_by_pid_result)
          expect(::ObjectSpace).to receive(:define_finalizer).and_call_original
          expect(server_instance.pid).to eq(pid)
          expect(server_instance.port).to eq(port)
        end
      end

      context 'when port not passed' do
        let(:port) { random_port }
        let(:args) { {} }

        it 'creates and runs server instance, gets port from pid' do
          expect(::Kernel).to receive(:exec).with(compose_command(converted_command_line_args)).and_return(exec_result)
          expect(::Kernel).to receive(:fork) { |&block| expect(block.call).to eq(exec_result) }.and_return(pid)
          expect(::Kernel).to receive(:`).with(cmd_lsof_port_by_pid(pid)).twice.and_return(lsof_port_by_pid_result(port))
          expect(::ObjectSpace).to receive(:define_finalizer).and_call_original
          expect(server_instance.pid).to eq(pid)
          expect(server_instance.port).to eq(port)
        end
      end
    end

    describe 'Failure' do
      context 'when current system dependencies do not satisfy gem requirements' do
        subject(:server_instance) { described_class.new(deps_checker, args_builder) }

        let(:args_builder) { SmtpMock::CommandLineArgsBuilder }
        let(:deps_checker) { SmtpMock::Dependency }

        it do
          expect(deps_checker).to receive(:verify_dependencies).and_call_original
          expect(deps_checker).to receive(:smtpmock?).and_return(false)
          expect { server_instance }
            .to raise_error(
              SmtpMock::Error::Dependency,
              SmtpMock::Error::Dependency::SMTPMOCK_NOT_INSTALLED
            )
        end

        it do
          expect(deps_checker).to receive(:verify_dependencies).and_call_original
          expect(deps_checker).to receive(:smtpmock?).and_return(true)
          expect(deps_checker).to receive(:lsof?).and_return(false)
          expect { server_instance }
            .to raise_error(
              SmtpMock::Error::Dependency,
              SmtpMock::Error::Dependency::LSOF_NOT_INSTALLED
            )
        end
      end

      context 'when invalid keyword argument passed' do
        subject(:server_instance) { described_class.new(invalid_argument: 42) }

        it do
          expect(SmtpMock::Dependency).to receive(:verify_dependencies)
          expect { server_instance }.to raise_error(SmtpMock::Error::Argument)
        end
      end

      context 'when smtpmock not starts' do
        subject(:server_instance) { described_class.new }

        it do
          expect(SmtpMock::Dependency).to receive(:verify_dependencies)
          expect(SmtpMock::CommandLineArgsBuilder).to receive(:call).and_return(converted_command_line_args)
          expect(::Kernel).to receive(:exec).with(compose_command(converted_command_line_args)).and_return(exec_result)
          expect(::Kernel).to receive(:fork) { |&block| expect(block.call).to eq(exec_result) }.and_return(pid)
          expect(::Kernel).to receive(:sleep).with(SmtpMock::Server::WARMUP_DELAY)
          expect(::Kernel).to receive(:`).with(cmd_lsof_port_by_pid(pid)).and_return('')
          expect { server_instance }.to raise_error(SmtpMock::Error::Server, SmtpMock::Error::Server::ERROR_MESSAGE)
        end
      end
    end
  end

  describe '#active?' do
    subject(:server_instance) { described_class.new(port: port) }

    let(:port) { random_port }

    before do
      allow(SmtpMock::Dependency).to receive(:verify_dependencies)
      allow(SmtpMock::CommandLineArgsBuilder).to receive(:call).with(port: port).and_return(converted_command_line_args)
      allow(::Kernel).to receive(:exec).with(compose_command(converted_command_line_args)).and_return(exec_result)
      allow(::Kernel).to receive(:fork).and_yield.and_return(pid)
      allow(::Kernel).to receive(:sleep).with(SmtpMock::Server::WARMUP_DELAY)
    end

    context 'when server is active' do
      it do
        expect(::Kernel).to receive(:`).with(cmd_lsof_port_by_pid(pid)).twice.and_return(lsof_port_by_pid_result)
        expect(server_instance.active?).to be(true)
      end
    end

    context 'when server is inactive' do
      it do
        expect(::Kernel).to receive(:`).with(cmd_lsof_port_by_pid(pid)).and_return(lsof_port_by_pid_result)
        server_instance
        expect(::Kernel).to receive(:`).with(cmd_lsof_port_by_pid(pid)).and_return('')
        expect(server_instance.active?).to be(false)
      end
    end
  end

  describe '#stop' do
    subject(:server_instance) { described_class.new(port: port) }

    let(:port) { random_port }

    before do
      allow(SmtpMock::Dependency).to receive(:verify_dependencies)
      allow(SmtpMock::CommandLineArgsBuilder).to receive(:call).with(port: port).and_return(converted_command_line_args)
      allow(::Kernel).to receive(:exec).with(compose_command(converted_command_line_args)).and_return(exec_result)
      allow(::Kernel).to receive(:fork).and_yield.and_return(pid)
      allow(::Kernel).to receive(:sleep).with(SmtpMock::Server::WARMUP_DELAY)
      allow(::Kernel).to receive(:`).with(cmd_lsof_port_by_pid(pid)).and_return(lsof_port_by_pid_result)
    end

    context 'when existent pid' do
      it 'stops current server by pid' do
        expect(SmtpMock::Server::Process)
          .to receive(:kill)
          .with(SmtpMock::Server::Process::SIGTERM, pid)
          .and_return(true)
        expect(server_instance.stop).to be(true)
      end
    end

    context 'when non-existent pid' do
      it 'stops current server by pid' do
        expect(SmtpMock::Server::Process)
          .to receive(:kill)
          .with(SmtpMock::Server::Process::SIGTERM, pid)
          .and_return(false)
        expect(server_instance.stop).to be(false)
      end
    end
  end

  describe '#stop!' do
    subject(:server_instance) { described_class.new(port: port) }

    let(:port) { random_port }

    before do
      allow(SmtpMock::Dependency).to receive(:verify_dependencies)
      allow(SmtpMock::CommandLineArgsBuilder).to receive(:call).with(port: port).and_return(converted_command_line_args)
      allow(::Kernel).to receive(:exec).with(compose_command(converted_command_line_args)).and_return(exec_result)
      allow(::Kernel).to receive(:fork).and_yield.and_return(pid)
      allow(::Kernel).to receive(:sleep).with(SmtpMock::Server::WARMUP_DELAY)
      allow(::Kernel).to receive(:`).with(cmd_lsof_port_by_pid(pid)).and_return(lsof_port_by_pid_result)
    end

    context 'when existent pid' do
      it 'stops current server by pid' do
        expect(SmtpMock::Server::Process)
          .to receive(:kill)
          .with(SmtpMock::Server::Process::SIGKILL, pid)
          .and_return(true)
        expect(server_instance.stop!).to be(true)
      end
    end

    context 'when non-existent pid' do
      it 'stops current server by pid' do
        expect(SmtpMock::Server::Process)
          .to receive(:kill)
          .with(SmtpMock::Server::Process::SIGKILL, pid)
          .and_return(false)
        expect(server_instance.stop!).to be(false)
      end
    end
  end
end

RSpec.describe SmtpMock::Server::Process do
  subject(:process) { described_class.kill(signal_number, pid) }

  let(:signal_number) { random_signal }
  let(:pid) { random_pid }

  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:SIGKILL) }
    it { expect(described_class).to be_const_defined(:SIGTERM) }
  end

  context 'when existent pid' do
    it do
      expect(::Process).to receive(:kill).with(signal_number, pid).and_return(1)
      expect(process).to be(true)
    end
  end

  context 'when non-existent pid' do
    it do
      expect(::Process).to receive(:kill).with(signal_number, pid).and_raise(::Errno::ESRCH)
      expect(process).to be(false)
    end
  end
end
