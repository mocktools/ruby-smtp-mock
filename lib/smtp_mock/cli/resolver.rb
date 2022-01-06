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

          parser.on('-s', '--sudo', 'Run command as sudo') do
            self.sudo = true
          end

          parser.on('-iPATH', '--install=PATH', 'Install smtpmock to the existing path') do |argument|
            self.install_path = argument
            return self.message = 'smtpmock is already installed' if ::File.exist?(binary_path)

            ::Kernel.system("cd #{install_path} && curl -sL #{SmtpMock::Cli::Resolver::DOWNLOAD_SCRIPT} | bash")
            ::Kernel.system("#{as_sudo}ln -s #{binary_path} #{SmtpMock::Dependency::SYMLINK}")

            self.message = 'smtpmock was installed successfully'
          end

          parser.on('-u', '--uninstall', 'Uninstall smtpmock') do
            current_smtpmock_path = SmtpMock::Dependency.smtpmock_path_by_symlink
            return self.message = 'smtpmock not installed yet' if current_smtpmock_path.empty?

            ::Kernel.system("#{as_sudo}unlink #{SmtpMock::Dependency::SYMLINK}")
            ::Kernel.system("rm #{current_smtpmock_path}")

            self.message = 'smtpmock was uninstalled successfully'
          end

          self.success = true

          parser.on('-h', '--help', 'Prints help') do
            ::Kernel.puts(parser.to_s)
            ::Kernel.exit
          end
        end

        opt_parser.parse(command_line_args)
      end

      private

      def binary_path
        "#{install_path}/smtpmock"
      end

      def as_sudo
        return 'sudo ' if sudo
      end
    end
  end
end
