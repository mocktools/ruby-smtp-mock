# frozen_string_literal: true

module SmtpMock
  module Error
    class Dependency < ::RuntimeError
      SMTPMOCK_NOT_INSTALLED = 'smtpmock is required system dependency. Run `bundle exec smtp_mock -h` for details'
      LSOF_NOT_INSTALLED = 'lsof is required system dependency. For using smtp_mock gem please install lsof for your system'
    end
  end
end
