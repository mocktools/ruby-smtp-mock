# frozen_string_literal: true

require 'dry/struct'

module SmtpMock
  Types = ::Class.new { include Dry.Types }

  module Error
    Argument = ::Class.new(::ArgumentError)
  end

  require_relative '../smtp_mock/version'
  require_relative '../smtp_mock/command_line_args_builder'
  require_relative '../smtp_mock/cli/resolver'
  require_relative '../smtp_mock/cli'
  # require_relative '../smtp_mock/server'
end
