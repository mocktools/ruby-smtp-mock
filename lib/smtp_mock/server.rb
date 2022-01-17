# frozen_string_literal: true

module SmtpMock
  class Server
    attr_reader :pid, :port

    def initialize( # rubocop:disable Metrics/ParameterLists
      deps_handler = SmtpMock::Dependency,
      port_checker = SmtpMock::Server::Port,
      args_builder = SmtpMock::CommandLineArgsBuilder,
      process = SmtpMock::Server::Process,
      **args
    )
      deps_handler.verify_dependencies
      args[:port] = port_checker.random_free_port unless args.include?(:port)
      @command_line_args, @port = args_builder.call(**args), args[:port]
      @deps_handler, @port_checker, @process = deps_handler, port_checker, process
      run
    end

    def active?
      process_alive? && port_open?
    end

    def stop
      process_kill(SmtpMock::Server::Process::SIGTERM)
    end

    def stop!
      process_kill(SmtpMock::Server::Process::SIGKILL)
    end

    private

    attr_reader :deps_handler, :command_line_args, :port_checker, :process
    attr_writer :pid, :port

    def process_kill(signal_number)
      process.kill(signal_number, pid)
    end

    def compose_command
      deps_handler.compose_command(command_line_args)
    end

    def process_alive?
      process.alive?(pid)
    end

    def port_open?
      port_checker.port_open?(port)
    end

    def run
      self.pid = process.create(compose_command)
      ::Kernel.at_exit { stop! }
    end
  end
end
