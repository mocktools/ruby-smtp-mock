# frozen_string_literal: true

RSpec.describe SmtpMock::Dependency do
  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:BINARY_SHORTCUT) }
    it { expect(described_class).to be_const_defined(:SYMLINK) }
    it { expect(described_class).to be_const_defined(:VERSION_REGEX_PATTERN) }
  end

  describe '.smtpmock_path_by_symlink' do
    subject(:smtpmock_path_by_symlink) { described_class.smtpmock_path_by_symlink }

    it 'returns smtpmock path by symlink' do
      expect(::Kernel).to receive(:`).with("readlink #{SmtpMock::Dependency::SYMLINK}")
      smtpmock_path_by_symlink
    end
  end

  describe '.smtpmock?' do
    subject(:smtpmock?) { described_class.smtpmock? }

    before { allow(described_class).to receive(:smtpmock_path_by_symlink).and_return(smtpmock_path) }

    context 'when smtpmock path found by symlink' do
      let(:smtpmock_path) { 'smtpmock_path' }

      it { is_expected.to be(true) }
    end

    context 'when smtpmock path not found by symlink' do
      let(:smtpmock_path) { '' }

      it { is_expected.to be(false) }
    end
  end

  describe '.verify_dependencies' do
    subject(:verify_dependencies) { described_class.verify_dependencies }

    context 'when smtpmock version satisfies minimum version' do
      it 'not raises SmtpMock::Error::Dependency error' do
        expect(described_class).to receive(:smtpmock?).and_return(true)
        expect(described_class).to receive(:version).and_return(SmtpMock::SMTPMOCK_MIN_VERSION)
        expect(verify_dependencies).to match(/(\d+)(\.\g<1>){2}/)
      end
    end

    context 'when not supported smtpmock version installed' do
      shared_examples 'raises SmtpMock::Error::Dependency error' do
        it do
          expect(described_class).to receive(:smtpmock?).and_return(true)
          expect(described_class).to receive(:version).and_return(version)
          expect { verify_dependencies }
            .to raise_error(
              SmtpMock::Error::Dependency,
              SmtpMock::Error::Dependency::SMTPMOCK_MIN_VERSION
            )
        end
      end

      context 'when failed to determine current smtpmock version' do
        let(:version) { nil }

        include_examples 'raises SmtpMock::Error::Dependency error'
      end

      context 'when current smtpmock version does not satisfy the minimum version' do
        let(:version) { '1.4.9' }

        include_examples 'raises SmtpMock::Error::Dependency error'
      end
    end

    context 'when smtpmock not installed' do
      it do
        expect(described_class).to receive(:smtpmock?).and_return(false)
        expect { verify_dependencies }
          .to raise_error(
            SmtpMock::Error::Dependency,
            SmtpMock::Error::Dependency::SMTPMOCK_NOT_INSTALLED
          )
      end
    end
  end

  describe '.compose_command' do
    subject(:compose_command) { described_class.compose_command(command_line_args) }

    context 'when command line args are not empty' do
      let(:command_line_args) { '-x -y -z 42' }

      it { is_expected.to eq("#{SmtpMock::Dependency::BINARY_SHORTCUT} #{command_line_args}") }
    end

    context 'when command line args is empty' do
      let(:command_line_args) { '' }

      it { is_expected.to eq(SmtpMock::Dependency::BINARY_SHORTCUT) }
    end
  end

  describe '.version' do
    subject(:version) { described_class.version }

    before { allow(::Kernel).to receive(:`).with("#{SmtpMock::Dependency::BINARY_SHORTCUT} -v").and_return(ver) }

    context 'when failed to determine smtpmock version' do
      let(:ver) { '' }

      it { is_expected.to be_nil }
    end

    context 'when it was possible to determine smtpmock version' do
      let(:ver) { "smtpmock: 3.14.0\ncommit: 2128506\nbuilt at: 2022-01-31T23:32:59Z" }

      it { is_expected.to match(/(\d+)(\.\g<1>){2}/) }
    end
  end

  describe '.minimal_version?' do
    subject(:minimal_version?) { described_class.send(:minimal_version?, current_version) }

    context 'when failed to determine current smtpmock version' do
      let(:current_version) { nil }

      it { is_expected.to be(false) }
    end

    context 'when current smtpmock version does not satisfy the minimum version' do
      let(:current_version) { '1.4.9' }

      it { is_expected.to be(false) }
    end

    context 'when current smtpmock version satisfies the minimum version' do
      let(:current_version) { SmtpMock::SMTPMOCK_MIN_VERSION }

      it { is_expected.to be(true) }
    end
  end
end
