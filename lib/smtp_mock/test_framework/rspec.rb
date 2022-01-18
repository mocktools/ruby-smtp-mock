# frozen_string_literal: true

require 'rspec/core'
require_relative '../../smtp_mock'
require_relative './rspec/interface'
require_relative './rspec/helper'

RSpec.configure do |config|
  config.after { SmtpMock::TestFramework::RSpec::Interface.stop_server! }
end
