# frozen_string_literal: true

require_relative './interface'

module SmtpMock
  module TestFramework
    module RSpec
      module Helper
        def smtp_mock_server(**options)
          SmtpMock::TestFramework::RSpec::Interface.start_server(**options)
        end
      end
    end
  end
end
