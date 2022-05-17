# frozen_string_literal: true

module SmtpMock
  module ContextGeneratorHelper
    def random_ip_v4_address
      ffaker.ip_v4_address
    end

    def random_hostname
      ffaker.domain_name
    end

    def random_email
      ffaker.email
    end

    def random_pid
      random.rand(1_000..2_000)
    end

    def random_port_number
      random.rand(49_152..65_535)
    end

    def random_signal
      random.rand(1..39)
    end

    def random_message
      FFaker::Lorem.sentence
    end

    def random_sem_version
      ::Array.new(3) { rand(0..42) }.join('.')
    end

    private

    def ffaker
      FFaker::Internet
    end

    def random
      ::Random
    end
  end
end
