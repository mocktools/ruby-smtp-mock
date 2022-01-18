# frozen_string_literal: true

module SmtpMock
  module TestFramework
    module RSpec
      module Interface
        class << self
          attr_reader :smtp_mock_server

          def start_server(**options)
            @smtp_mock_server ||= SmtpMock.start_server(**options) # rubocop:disable Naming/MemoizedInstanceVariableName
          end

          def clear_server!
            @smtp_mock_server = nil
          end

          def stop_server!
            return unless smtp_mock_server

            smtp_mock_server.stop!
            clear_server!
            true
          end
        end
      end
    end
  end
end
