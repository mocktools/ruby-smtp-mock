# frozen_string_literal: true

module SmtpMock
  module Error
    class Dependency < ::RuntimeError
      SMTPMOCK_NOT_INSTALLED = 'smtpmock is required system dependency. Run `bundle exec smtp_mock -h` for details'
    end
  end
end
