# frozen_string_literal: true

require 'dry/struct'

module SmtpMock
  Types = ::Class.new { include Dry.Types }

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
end
