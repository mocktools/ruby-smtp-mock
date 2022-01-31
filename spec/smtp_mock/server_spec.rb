# frozen_string_literal: true

RSpec.describe SmtpMock::Server do
  let(:port) { random_port_number }
  let(:converted_command_line_args) { '-a -b 42' }
  let(:pid) { random_pid }

  describe '.new' do
    describe 'Success' do
      subject(:server_instance) { described_class.new(deps_checker, port_checker, args_builder, process, **args) }

      let(:deps_checker) { SmtpMock::Dependency }
      let(:port_checker) { class_double('ServerPort') }
      let(:process) { class_double('ServerProcess') }
      let(:args_builder) { class_double('CommandLineArgsBuilder') }
      let(:host) { random_ip_v4_address }
      let(:composed_command_with_args) { compose_command(converted_command_line_args) }
      let(:version) { ::Array.new(3) { ::Random.rand(1..10) }.join('.') }

      before do
        allow(deps_checker).to receive(:verify_dependencies).and_return(version)
        allow(deps_checker)
          .to receive(:compose_command)
          .with(converted_command_line_args)
          .and_return(composed_command_with_args)
        allow(::Kernel).to receive(:at_exit)
      end

      context 'when port passed' do
        let(:args) { { host: host, port: port } }

        it 'creates and runs server instance, gets port from args' do
          expect(port_checker).not_to receive(:random_free_port)
          expect(args_builder).to receive(:call).with(args).and_return(converted_command_line_args)
          expect(process).to receive(:create).with(composed_command_with_args).and_return(pid)
          expect(server_instance.pid).to eq(pid)
          expect(server_instance.port).to eq(port)
          expect(server_instance.version).to eq(version)
        end
      end

      context 'when port not passed' do
        let(:args) { { host: host } }

        it 'creates and runs server instance, gets port from SmtpMock::Server::Port' do
          expect(port_checker).to receive(:random_free_port).and_return(port)
          expect(args_builder).to receive(:call).with(args.merge(port: port)).and_return(converted_command_line_args)
          expect(process).to receive(:create).with(composed_command_with_args).and_return(pid)
          expect(server_instance.pid).to eq(pid)
          expect(server_instance.port).to eq(port)
          expect(server_instance.version).to eq(version)
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

        let(:err_output) { SmtpMock::Server::Process.send(:err_log) }
        let(:err_output_path) { '../../../spec/support/fixtures/err_log_with_context' }

        before do
          reset_err_log
          stub_const('SmtpMock::Server::Process::TMP_LOG_PATH', err_output_path)
        end

        after { reset_err_log }

        it do
          expect(SmtpMock::Dependency).to receive(:verify_dependencies)
          expect(SmtpMock::Server::Port).to receive(:random_free_port)
          expect(SmtpMock::CommandLineArgsBuilder).to receive(:call).and_return(converted_command_line_args)
          expect(::Process).to receive(:spawn).with(compose_command(converted_command_line_args), err: err_output)
          expect { server_instance }.to raise_error(SmtpMock::Error::Server, 'Some error context here')
        end
      end
    end
  end

  describe '#active?' do
    subject(:server_instance) { described_class.new }

    before do
      allow(SmtpMock::Dependency).to receive(:verify_dependencies)
      allow(SmtpMock::Server::Port).to receive(:random_free_port).and_return(port)
      allow(SmtpMock::CommandLineArgsBuilder).to receive(:call).and_return(converted_command_line_args)
      allow(SmtpMock::Server::Process).to receive(:create).with(compose_command(converted_command_line_args)).and_return(pid)
      allow(::Kernel).to receive(:at_exit)
    end

    context 'when server is active' do
      it do
        expect(SmtpMock::Server::Process).to receive(:alive?).with(pid).and_return(true)
        expect(SmtpMock::Server::Port).to receive(:port_open?).with(port).and_return(true)
        expect(server_instance.active?).to be(true)
      end
    end

    context 'when server is inactive' do
      context 'when process is dead' do
        it do
          expect(SmtpMock::Server::Process).to receive(:alive?).with(pid).and_return(false)
          expect(SmtpMock::Server::Port).not_to receive(:port_open?)
          expect(server_instance.active?).to be(false)
        end
      end

      context 'when port is closed' do
        it do
          expect(SmtpMock::Server::Process).to receive(:alive?).with(pid).and_return(true)
          expect(SmtpMock::Server::Port).to receive(:port_open?).with(port).and_return(false)
          expect(server_instance.active?).to be(false)
        end
      end
    end
  end

  describe '#stop' do
    subject(:server_instance) { described_class.new }

    before do
      allow(SmtpMock::Dependency).to receive(:verify_dependencies)
      allow(SmtpMock::Server::Port).to receive(:random_free_port).and_return(port)
      allow(SmtpMock::CommandLineArgsBuilder).to receive(:call).and_return(converted_command_line_args)
      allow(SmtpMock::Server::Process).to receive(:create).with(compose_command(converted_command_line_args)).and_return(pid)
      allow(::Kernel).to receive(:at_exit)
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
    subject(:server_instance) { described_class.new }

    let(:port) { random_port_number }

    before do
      allow(SmtpMock::Dependency).to receive(:verify_dependencies)
      allow(SmtpMock::Server::Port).to receive(:random_free_port).and_return(port)
      allow(SmtpMock::CommandLineArgsBuilder).to receive(:call).and_return(converted_command_line_args)
      allow(SmtpMock::Server::Process).to receive(:create).with(compose_command(converted_command_line_args)).and_return(pid)
      allow(::Kernel).to receive(:at_exit)
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
