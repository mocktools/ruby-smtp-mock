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

  describe '#random_pid' do
    it 'returns random pid' do
      expect(::Random).to receive(:rand).with(1_000..2_000).and_call_original
      expect(random_pid).to be_an_instance_of(::Integer)
    end
  end

  describe '#random_port' do
    it 'returns random port' do
      expect(::Random).to receive(:rand).with(49_152..65_535).and_call_original
      expect(random_port).to be_an_instance_of(::Integer)
    end
  end

  describe '#random_signal' do
    it 'returns random signal number' do
      expect(::Random).to receive(:rand).with(1..39).and_call_original
      expect(random_signal).to be_an_instance_of(::Integer)
    end
  end
end
