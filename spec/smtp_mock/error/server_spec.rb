# frozen_string_literal: true

RSpec.describe SmtpMock::Error::Server do
  it { expect(described_class).to be < ::RuntimeError }
end
