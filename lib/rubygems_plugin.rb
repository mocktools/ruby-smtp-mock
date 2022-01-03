# frozen_string_literal: true

Gem.post_install do
  unless ::File.exist?('bin/smtpmock')
    `cd ./bin && curl -sL https://raw.githubusercontent.com/mocktools/go-smtp-mock/master/script/download.sh | bash`
    puts 'Downloaded latest smtpmock binary'
  end
end
