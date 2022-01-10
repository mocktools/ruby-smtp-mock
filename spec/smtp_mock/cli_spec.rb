# frozen_string_literal: true

RSpec.describe SmtpMock::Cli do
  describe '.call' do
    subject(:command) { described_class.call(command_line_args, command_class) }

    let(:command_line_args) { [] }
    let(:command_class) { class_double('SmtpMock::Cli::Command') }
    let(:message) { 'some message' }
    let(:command_instance) do
      described_class::Command.new.tap do |object|
        object.message = message
        object.success = success
      end
    end

    before do
      allow(command_class).to receive(:new).and_return(command_instance)
      allow(command_instance).to receive(:resolve).with(command_line_args)
    end

    context 'when succesful command' do
      let(:success) { true }

      it 'prints message to stdout and exits with status 0' do
        expect(::Kernel).to receive(:puts).with(message)
        expect(::Kernel).to receive(:exit).with(0)
        command
      end
    end

    context 'when failed command' do
      let(:success) { false }

      it 'prints message to stdout and exits with status 1' do
        expect(::Kernel).to receive(:puts).with(message)
        expect(::Kernel).to receive(:exit).with(1)
        command
      end
    end
  end
end

RSpec.describe SmtpMock::Cli::Command do
  subject(:command_instance) { described_class.new }

  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:USE_CASE) }
    it { expect(described_class).to be_const_defined(:DOWNLOAD_SCRIPT) }
  end

  it 'have specified attr accesptors' do
    expect(command_instance.members).to match_array(%i[install_path sudo success message])
  end

  describe '#resolve' do
    subject(:resolve) { command_instance.resolve(command_line_args) }

    context 'when sudo key passed' do
      %w[-s --sudo].each do |key|
        let(:command_line_args) { [key] }

        it { expect { resolve }.to change(command_instance, :sudo).from(nil).to(true) }
      end
    end

    context 'when install key passed' do
      [%w[-i some_path], %w[--install=some_path]].each do |keys|
        let(:command_line_args) { keys }

        context 'when smtpmock is already installed' do
          it 'not installes binary file and not addes symlink' do
            expect(::File).to receive(:exist?).with('some_path/smtpmock').and_return(true)
            expect { resolve }
              .to change(command_instance, :install_path)
              .from(nil).to('some_path')
              .and change(command_instance, :message)
              .from(nil).to('smtpmock is already installed')
          end
        end

        context 'when smtpmock is not installed yet' do
          it 'installes binary file and addes symlink' do
            expect(::File).to receive(:exist?).with('some_path/smtpmock').and_return(false)
            expect(::Kernel).to receive(:system).with("cd some_path && curl -sL #{SmtpMock::Cli::Resolver::DOWNLOAD_SCRIPT} | bash")
            expect(::Kernel).to receive(:system).with("ln -s some_path/smtpmock #{SmtpMock::Dependency::SYMLINK}")
            expect { resolve }
              .to change(command_instance, :install_path)
              .from(nil).to('some_path')
              .and change(command_instance, :message)
              .from(nil).to('smtpmock was installed successfully')
          end
        end
      end
    end

    context 'when sudo with install key passed' do
      [%w[-s -i some_path], %w[--sudo --install=some_path]].each do |keys|
        let(:command_line_args) { keys }

        context 'when smtpmock is already installed' do
          it 'not installes binary file and not addes symlink' do
            expect(::File).to receive(:exist?).with('some_path/smtpmock').and_return(true)
            expect { resolve }
              .to change(command_instance, :sudo)
              .from(nil).to(true)
              .and change(command_instance, :install_path)
              .from(nil).to('some_path')
              .and change(command_instance, :message)
              .from(nil).to('smtpmock is already installed')
          end
        end

        context 'when smtpmock is not installed yet' do
          it 'installes binary file and addes symlink' do
            expect(::File).to receive(:exist?).with('some_path/smtpmock').and_return(false)
            expect(::Kernel).to receive(:system).with("cd some_path && curl -sL #{SmtpMock::Cli::Resolver::DOWNLOAD_SCRIPT} | bash")
            expect(::Kernel).to receive(:system).with("sudo ln -s some_path/smtpmock #{SmtpMock::Dependency::SYMLINK}")
            expect { resolve }
              .to change(command_instance, :sudo)
              .from(nil).to(true)
              .and change(command_instance, :install_path)
              .from(nil).to('some_path')
              .and change(command_instance, :message)
              .from(nil).to('smtpmock was installed successfully')
          end
        end
      end
    end

    context 'when uninstall key passed' do
      %w[-u --uninstall].each do |key|
        let(:command_line_args) { [key] }

        before { stub_const('SmtpMock::Dependency::SYMLINK', symlink) }

        context 'when non-existent symlink' do
          let(:symlink) { '/usr/local/bin/non-existent-smtpmock' }

          it 'not removes symlink and binary file' do
            expect(SmtpMock::Dependency).to receive(:smtpmock_path_by_symlink).and_return('')
            expect { resolve }.to change(command_instance, :message).from(nil).to('smtpmock not installed yet')
          end
        end

        context 'when existent symlink' do
          let(:symlink) { '/usr/local/bin/existent-smtpmock' }
          let(:binary_path) { '/some_ninary_path' }

          it 'removes symlink and binary file' do
            expect(SmtpMock::Dependency).to receive(:smtpmock_path_by_symlink).and_return(binary_path)
            expect(::Kernel).to receive(:system).with("unlink #{SmtpMock::Dependency::SYMLINK}")
            expect(::Kernel).to receive(:system).with("rm #{binary_path}")
            expect { resolve }.to change(command_instance, :message).from(nil).to('smtpmock was uninstalled successfully')
          end
        end
      end
    end

    context 'when sudo with uninstall key passed' do
      [%w[-s -u], %w[--sudo --uninstall]].each do |keys|
        let(:command_line_args) { keys }

        before { stub_const('SmtpMock::Dependency::SYMLINK', symlink) }

        context 'when non-existent symlink' do
          let(:symlink) { '/usr/local/bin/non-existent-smtpmock' }

          it 'not removes symlink and binary file' do
            expect(SmtpMock::Dependency).to receive(:smtpmock_path_by_symlink).and_return('')
            expect { resolve }
              .to change(command_instance, :sudo)
              .from(nil).to(true)
              .and change(command_instance, :message)
              .from(nil).to('smtpmock not installed yet')
          end
        end

        context 'when existent symlink' do
          let(:symlink) { '/usr/local/bin/existent-smtpmock' }
          let(:binary_path) { '/some_ninary_path' }

          it 'removes symlink and binary file' do
            expect(SmtpMock::Dependency).to receive(:smtpmock_path_by_symlink).and_return(binary_path)
            expect(::Kernel).to receive(:system).with("sudo unlink #{SmtpMock::Dependency::SYMLINK}")
            expect(::Kernel).to receive(:system).with("rm #{binary_path}")
            expect { resolve }
              .to change(command_instance, :sudo)
              .from(nil).to(true)
              .and change(command_instance, :message)
              .from(nil).to('smtpmock was uninstalled successfully')
          end
        end
      end
    end

    context 'when help key passed' do
      %w[-h --help].each do |key|
        let(:command_line_args) { [key] }
        let(:expected_string) do
          %(#{SmtpMock::Cli::Resolver::USE_CASE}
    -s, --sudo                       Run command as sudo
    -i, --install=PATH               Install smtpmock to the existing path
    -u, --uninstall                  Uninstall smtpmock
    -h, --help                       Prints help
)
        end

        it do
          expect(::Kernel).to receive(:puts).with(expected_string)
          expect(::Kernel).to receive(:exit)
          resolve
        end
      end
    end
  end

  describe '#binary_path' do
    subject(:binary_path) { command_instance.send(:binary_path) }

    let(:install_path) { 'some_install_path' }

    before { command_instance.install_path = install_path }

    it { is_expected.to eq("#{install_path}/smtpmock") }
  end

  describe '#as_sudo' do
    subject(:as_sudo) { command_instance.send(:as_sudo) }

    context 'when sudo true' do
      before { command_instance.sudo = true }

      it { is_expected.to eq('sudo ') }
    end

    context 'when sudo false' do
      it { is_expected.to be_nil }
    end
  end
end
