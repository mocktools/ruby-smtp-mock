# frozen_string_literal: true

RSpec::Matchers.define(:have_message_context) do |message|
  match { |net_smtp_instance| net_smtp_instance.message.strip.eql?(message) }
end
