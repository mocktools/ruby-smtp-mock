# frozen_string_literal: true

RSpec.describe SmtpMock::Error::Server do
  subject(:error_instance) { described_class.new }

  let(:error_context) { SmtpMock::Error::Server::ERROR_MESSAGE }

  it { expect(described_class).to be_const_defined(:ERROR_MESSAGE) }
  it { expect(described_class).to be < ::RuntimeError }
  it { expect(error_instance).to be_an_instance_of(described_class) }
  it { expect(error_instance.to_s).to eq(error_context) }
end
