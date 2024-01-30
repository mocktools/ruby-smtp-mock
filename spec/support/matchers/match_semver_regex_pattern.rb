# frozen_string_literal: true

RSpec::Matchers.define(:match_semver_regex_pattern) do
  match { |semver_string| /\d+\.\d+.\d+/.match?(semver_string) }
end
