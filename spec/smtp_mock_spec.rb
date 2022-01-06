# frozen_string_literal: true

RSpec.describe SmtpMock do
  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:DOWNLOAD_SCRIPT) }
    it { expect(described_class).to be_const_defined(:BIN_DIR) }
    it { expect(described_class).to be_const_defined(:BINARY_PATH) }
    it { expect(described_class).to be_const_defined(:INSTALL) }
    it { expect(described_class).to be_const_defined(:INSTALLATION_SUCCESSFUL) }
    it { expect(described_class).to be_const_defined(:INSTALLATION_FAILED) }
  end

  describe 'errors' do
    it { expect(described_class::Error::Argument).to be < ::ArgumentError }
  end
end
