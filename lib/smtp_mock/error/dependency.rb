# frozen_string_literal: true

module SmtpMock
  module Error
    class Dependency < ::RuntimeError
      SMTPMOCK_NOT_INSTALLED = 'smtpmock is required system dependency. Run `bundle exec smtp_mock -h` for details'
      SMTPMOCK_MIN_VERSION = "smtpmock #{SmtpMock::SMTPMOCK_MIN_VERSION} or higher is required. Run `bundle exec smtp_mock -g` for version upgrade"
    end
  end
end
