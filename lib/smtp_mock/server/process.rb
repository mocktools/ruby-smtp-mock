# frozen_string_literal: true

module SmtpMock
  class Server
    class Process
      SIGNULL = 0
      SIGKILL = 9
      SIGTERM = 15
      TMP_LOG_PATH = '../../../tmp/err_log'
      WARMUP_DELAY = 0.1

      class << self
        def create(command)
          pid = ::Process.spawn(command, err: err_log)
          ::Kernel.sleep(SmtpMock::Server::Process::WARMUP_DELAY)
          error_context = ::IO.readlines(err_log)[0]
          raise SmtpMock::Error::Server, error_context.strip if error_context
          pid
        end

        def alive?(pid)
          ::Process.kill(SmtpMock::Server::Process::SIGNULL, pid)
          true
        rescue ::Errno::ESRCH
          false
        end

        def kill(signal_number, pid)
          ::Process.detach(pid)
          ::Process.kill(signal_number, pid)
          true
        rescue ::Errno::ESRCH
          false
        end

        private

        def err_log
          @err_log ||= ::File.expand_path(SmtpMock::Server::Process::TMP_LOG_PATH, ::File.dirname(__FILE__))
        end
      end
    end
  end
end
