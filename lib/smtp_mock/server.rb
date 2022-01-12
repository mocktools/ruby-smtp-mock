# frozen_string_literal: true

module SmtpMock
  class Server
    WARMUP_DELAY = 0.5
    LSOF_USED_PORT_PATTERN = /:(\d+) \(LISTEN\)/.freeze

    class Process
      SIGKILL = 9
      SIGTERM = 15

      def self.kill(signal_number, pid)
        !!::Process.kill(signal_number, pid)
      rescue ::Errno::ESRCH
        false
      end
    end

    attr_reader :pid, :port

    def initialize(
      deps_checker = SmtpMock::Dependency,
      args_builder = SmtpMock::CommandLineArgsBuilder,
      process = SmtpMock::Server::Process,
      **args
    )
      deps_checker.verify_dependencies
      @command_line_args = args_builder.call(**args)
      @port = args[:port]
      @process = process
      run
    end

    def active?
      !lsof.empty?
    end

    def stop
      process_kill(SmtpMock::Server::Process::SIGTERM)
    end

    def stop!
      process_kill(SmtpMock::Server::Process::SIGKILL)
    end

    private

    attr_reader :command_line_args, :process
    attr_writer :pid, :port

    def process_kill(signal_number)
      process.kill(signal_number, pid)
    end

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
