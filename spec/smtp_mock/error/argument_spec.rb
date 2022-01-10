# frozen_string_literal: true

RSpec.describe SmtpMock::Error::Argument do
  it { expect(described_class).to be < ::ArgumentError }
end
