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
      deps_handler = SmtpMock::Dependency,
      args_builder = SmtpMock::CommandLineArgsBuilder,
      process = SmtpMock::Server::Process,
      **args
    )
      deps_handler.verify_dependencies
      @command_line_args, @port = args_builder.call(**args), args[:port]
      @deps_handler, @process = deps_handler, process
      run
    end

    def active?
      return false unless process
      !lsof.empty?
    end

    def stop
      process_kill(SmtpMock::Server::Process::SIGTERM)
    end

    def stop!
      process_kill(SmtpMock::Server::Process::SIGKILL)
    end

    private

    attr_reader :deps_handler, :command_line_args, :process
    attr_writer :pid, :port

    def process_kill(signal_number)
      process.kill(signal_number, pid)
    end

    def compose_command
      deps_handler.compose_command(command_line_args)
    end

    def lsof
      ::Kernel.public_send(:`, "lsof -aPi -p #{pid}")
    end

    def run
      self.pid = ::Kernel.fork { ::Kernel.exec(compose_command) }
      ::Kernel.sleep(SmtpMock::Server::WARMUP_DELAY)
      raise SmtpMock::Error::Server unless active?
      ::ObjectSpace.define_finalizer(self, proc { stop! })
      self.port ||= lsof[SmtpMock::Server::LSOF_USED_PORT_PATTERN, 1].to_i
    end
  end
end
