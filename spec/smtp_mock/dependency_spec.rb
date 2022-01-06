# frozen_string_literal: true

RSpec.describe SmtpMock::Dependency do
  describe 'defined constants' do
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
end
