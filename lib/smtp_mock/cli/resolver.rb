# frozen_string_literal: true

module SmtpMock
  module Cli
    module Resolver
      require 'optparse'

      USE_CASE = 'Usage: smtp_mock [options], example: `bundle exec smtp_mock -s -i ~/existent_dir`'
      DOWNLOAD_SCRIPT = 'https://raw.githubusercontent.com/mocktools/go-smtp-mock/master/script/download.sh'

      def resolve(command_line_args) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        opt_parser = ::OptionParser.new do |parser|
          parser.banner = SmtpMock::Cli::Resolver::USE_CASE

          parser.on('-s', '--sudo', 'Run command as sudo') { self.sudo = true }

          parser.on('-iPATH', '--install=PATH', 'Install smtpmock to the existing path') do |argument|
            self.install_path = argument
            return self.message = 'smtpmock is already installed' if ::File.exist?(binary_path)

            install_to(install_path)
            ::Kernel.system("#{as_sudo}ln -s #{binary_path} #{SmtpMock::Dependency::SYMLINK}")
            self.message = 'smtpmock was installed successfully'
          end

          parser.on('-u', '--uninstall', 'Uninstall smtpmock') do
            return if not_installed? # rubocop:disable Lint/NonLocalExitFromIterator

            ::Kernel.system("#{as_sudo}unlink #{SmtpMock::Dependency::SYMLINK}")
            ::Kernel.system("rm #{current_smtpmock_path}")
            self.message = 'smtpmock was uninstalled successfully'
          end

          parser.on('-g', '--upgrade', 'Upgrade to latest version of smtpmock') do
            return if not_installed? # rubocop:disable Lint/NonLocalExitFromIterator

            install_to(current_smtpmock_path[%r{(.+)/.+}, 1])
            self.message = 'smtpmock was upgraded successfully'
          end

          parser.on('-h', '--help', 'Prints help') { self.message = parser.to_s }

          self.success = true
        end

        opt_parser.parse(command_line_args) # TODO: add error handler
      end

      private

      def binary_path
        "#{install_path}/smtpmock"
      end

      def install_to(install_path)
        ::Kernel.system("cd #{install_path} && curl -sL #{SmtpMock::Cli::Resolver::DOWNLOAD_SCRIPT} | bash")
      end

      def as_sudo
        return 'sudo ' if sudo
      end

      def current_smtpmock_path
        @current_smtpmock_path ||= SmtpMock::Dependency.smtpmock_path_by_symlink
      end

      def not_installed?
        return false unless current_smtpmock_path.empty?
        self.message = 'smtpmock not installed yet'
        true
      end
    end
  end
end
