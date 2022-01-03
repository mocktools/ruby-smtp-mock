# frozen_string_literal: true

require 'dry/struct'

module SmtpMock
  DOWNLOAD_SCRIPT = 'https://raw.githubusercontent.com/mocktools/go-smtp-mock/master/script/download.sh'
  BIN_DIR = ::File.expand_path("#{::File.dirname(__FILE__)}/../../bin")
  BINARY_PATH = ::File.expand_path('smtpmock', SmtpMock::BIN_DIR)
  INSTALL = "cd #{SmtpMock::BIN_DIR} && curl -sL #{SmtpMock::DOWNLOAD_SCRIPT} | bash"
  INSTALLATION_SUCCESSFUL = 'Installed latest smtpmock'
  INSTALLATION_FAILED = 'Installation failed. To retry please reinstall smtp_mock gem'

  Types = ::Class.new { include Dry.Types }

  module Error
    Argument = ::Class.new(::ArgumentError)
  end

  require_relative '../smtp_mock/version'
  require_relative '../smtp_mock/command_line_args_builder'
  # require_relative '../smtp_mock/server'
end
