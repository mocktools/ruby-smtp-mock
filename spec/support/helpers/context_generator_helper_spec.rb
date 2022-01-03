# frozen_string_literal: true

RSpec.describe SmtpMock::ContextGeneratorHelper, type: :helper do # rubocop:disable RSpec/FilePath
  describe '#random_ip_v4_address' do
    it 'returns random ip v4 address' do
      expect(FFaker::Internet).to receive(:ip_v4_address).and_call_original
      expect(random_ip_v4_address).to match(SmtpMock::CommandLineArgsBuilder::IP_ADDRESS_PATTERN)
    end
  end

  describe '#random_hostname' do
    it 'returns random hostname' do
      expect(FFaker::Internet).to receive(:domain_name).and_call_original
      expect(random_hostname).to be_an_instance_of(::String)
    end
  end

  describe '#random_email' do
    it 'returns random email' do
      expect(FFaker::Internet).to receive(:email).and_call_original
      expect(random_email).to match(/.+@.+/)
    end
  end
end
