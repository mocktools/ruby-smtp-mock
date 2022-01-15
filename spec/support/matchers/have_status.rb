# frozen_string_literal: true

RSpec::Matchers.define(:have_status) do |status|
  match { |net_smtp_instance| net_smtp_instance.status.to_i.eql?(status) }
end
