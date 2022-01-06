# frozen_string_literal: true

module SmtpMock
  module Dependency
    SYMLINK = '/usr/local/bin/smtpmock'

    # def verify_dependencies
    #   raise SmtpMock::Error::Dependency, SmtpMock::Error::Dependency::SMTPMOCK_NOT_INSTALLED unless smtpmock?
    #   raise SmtpMock::Error::Dependency, SmtpMock::Error::Dependency::LSOF_NOT_INSTALLED unless lsof?
    # end

    module_function

    def smtpmock_path_by_symlink
      ::Kernel.public_send(:`, "readlink #{SmtpMock::Dependency::SYMLINK}")
    end

    def smtpmock?
      !smtpmock_path_by_symlink.empty?
    end

    def lsof?
      !!::Kernel.system('lsof -v', %i[out err] => ::File::NULL)
    end
  end
end
