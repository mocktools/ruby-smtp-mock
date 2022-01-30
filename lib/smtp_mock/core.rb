# frozen_string_literal: true

module SmtpMock
  SMTPMOCK_MIN_VERSION = '1.5.0'

  module Error
    require_relative '../smtp_mock/error/argument'
    require_relative '../smtp_mock/error/dependency'
    require_relative '../smtp_mock/error/server'
  end

  require_relative '../smtp_mock/version'
  require_relative '../smtp_mock/dependency'
  require_relative '../smtp_mock/command_line_args_builder'
  require_relative '../smtp_mock/cli/resolver'
  require_relative '../smtp_mock/cli'
  require_relative '../smtp_mock/server/port'
  require_relative '../smtp_mock/server/process'
  require_relative '../smtp_mock/server'
end
