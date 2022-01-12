# frozen_string_literal: true

RSpec.describe SmtpMock::Dependency do
  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:BINARY_SHORTCUT) }
    it { expect(described_class).to be_const_defined(:SYMLINK) }
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

  describe '.lsof?' do
    subject(:lsof?) { described_class.lsof? }

    before do
      allow(::Kernel)
        .to receive(:system)
        .with('lsof -v', %i[out err] => ::File::NULL)
        .and_return(command_result)
    end

    context 'when lsof found' do
      let(:command_result) { true }

      it { is_expected.to be(true) }
    end

    context 'when lsof not found' do
      let(:command_result) { nil }

      it { is_expected.to be(false) }
    end
  end

  describe '.verify_dependencies' do
    subject(:verify_dependencies) { described_class.verify_dependencies }

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

    context 'when smtpmock installed, lsof not installed' do
      it do
        expect(described_class).to receive(:smtpmock?).and_return(true)
        expect(described_class).to receive(:lsof?).and_return(false)
        expect { verify_dependencies }
          .to raise_error(
            SmtpMock::Error::Dependency,
            SmtpMock::Error::Dependency::LSOF_NOT_INSTALLED
          )
      end
    end

    context 'when both smtpmock and lsof were installed' do
      it 'not raises SmtpMock::Error::Dependency' do
        expect(described_class).to receive(:smtpmock?).and_return(true)
        expect(described_class).to receive(:lsof?).and_return(true)
        expect(verify_dependencies).to be_nil
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
end
