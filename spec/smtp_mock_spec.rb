# frozen_string_literal: true

RSpec.describe SmtpMock do
  describe 'defined constants' do
    it { expect(described_class).to be_const_defined(:Types) }
  end
end
