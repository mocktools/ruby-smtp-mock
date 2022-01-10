# frozen_string_literal: true

module SmtpMock
  class Server
    WARMUP_DELAY = 0.5
    LSOF_USED_PORT_PATTERN = /:(\d+) \(LISTEN\)/.freeze

    attr_reader :pid, :port

    def initialize(
      deps_checker = SmtpMock::Dependency,
      args_builder = SmtpMock::CommandLineArgsBuilder,
      **args
    )
      deps_checker.verify_dependencies
      @command_line_args = args_builder.call(**args)
      @port = args[:port]
      run
    end

    def active?
      !lsof.empty?
    end

    def stop!
      ::Process.kill(9, pid)
    rescue ::Errno::ESRCH
      nil
    end

    private

    attr_reader :command_line_args
    attr_writer :pid, :port

    def lsof
      ::Kernel.public_send(:`, "lsof -aPi -p #{pid}")
    end

    def run
      self.pid = ::Kernel.fork { ::Kernel.exec("smtpmock #{command_line_args}") }
      ::Kernel.sleep(SmtpMock::Server::WARMUP_DELAY)
      raise SmtpMock::Error::Server unless active?
      ::ObjectSpace.define_finalizer(self, proc { stop! })
      self.port ||= lsof[SmtpMock::Server::LSOF_USED_PORT_PATTERN, 1].to_i
    end
  end
end
