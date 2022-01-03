# frozen_string_literal: true

require_relative 'smtp_mock'

Gem.post_install do
  unless ::File.exist?(SmtpMock::BINARY_PATH)
    puts(system(SmtpMock::INSTALL) ? SmtpMock::INSTALLATION_SUCCESSFUL : SmtpMock::INSTALLATION_FAILED)
  end
end
