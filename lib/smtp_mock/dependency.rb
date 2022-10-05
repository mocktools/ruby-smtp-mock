# frozen_string_literal: true

module SmtpMock
  module Dependency
    BINARY_SHORTCUT = 'smtpmock'
    SYMLINK = "/usr/local/bin/#{BINARY_SHORTCUT}"
    VERSION_REGEX_PATTERN = /#{BINARY_SHORTCUT}: (.+)/.freeze

    class << self
      def smtpmock_path_by_symlink
        ::Kernel.public_send(:`, "readlink #{SmtpMock::Dependency::SYMLINK}")
      end

      def smtpmock?
        !smtpmock_path_by_symlink.empty?
      end

      def verify_dependencies
        raise SmtpMock::Error::Dependency, SmtpMock::Error::Dependency::SMTPMOCK_NOT_INSTALLED unless smtpmock?
        current_version = version
        raise SmtpMock::Error::Dependency, SmtpMock::Error::Dependency::SMTPMOCK_MIN_VERSION unless minimal_version?(current_version)
        current_version
      end

      def compose_command(command_line_args)
        "#{SmtpMock::Dependency::BINARY_SHORTCUT} #{command_line_args}".strip
      end

      def version
        ::Kernel.public_send(
          :`,
          "#{SmtpMock::Dependency::BINARY_SHORTCUT} -v"
        )[SmtpMock::Dependency::VERSION_REGEX_PATTERN, 1]
      end

      private

      def minimal_version?(current_version)
        !!current_version && ::Gem::Version.new(current_version) >= ::Gem::Version.new(SmtpMock::SMTPMOCK_MIN_VERSION)
      end
    end
  end
end
