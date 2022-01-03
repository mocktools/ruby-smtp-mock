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

    private

    def ffaker
      FFaker::Internet
    end
  end
end
