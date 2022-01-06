# frozen_string_literal: true

RSpec.describe SmtpMock::Error::Dependency do
  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:SMTPMOCK_NOT_INSTALLED) }
    it { expect(described_class).to be_const_defined(:LSOF_NOT_INSTALLED) }
  end

  it { expect(described_class).to be < ::RuntimeError }
end
