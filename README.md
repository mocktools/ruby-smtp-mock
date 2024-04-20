# ![Ruby SmtpMock - mimic any 📤 SMTP server behavior for your test environment with fake SMTP server](https://repository-images.githubusercontent.com/443795043/81ce5b00-0915-4dd0-93ad-88e6699e18cd)

[![Maintainability](https://api.codeclimate.com/v1/badges/315c5fff7449a11868dd/maintainability)](https://codeclimate.com/github/mocktools/ruby-smtp-mock/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/315c5fff7449a11868dd/test_coverage)](https://codeclimate.com/github/mocktools/ruby-smtp-mock/test_coverage)
[![CircleCI](https://circleci.com/gh/mocktools/ruby-smtp-mock/tree/master.svg?style=svg)](https://circleci.com/gh/mocktools/ruby-smtp-mock/tree/master)
[![Gem Version](https://badge.fury.io/rb/smtp_mock.svg)](https://badge.fury.io/rb/smtp_mock)
[![Downloads](https://img.shields.io/gem/dt/smtp_mock.svg?colorA=004d99&colorB=0073e6)](https://rubygems.org/gems/smtp_mock)
[![In Awesome Ruby](https://raw.githubusercontent.com/sindresorhus/awesome/main/media/mentioned-badge.svg)](https://github.com/markets/awesome-ruby)
[![GitHub](https://img.shields.io/github/license/mocktools/ruby-smtp-mock)](LICENSE.txt)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v1.4%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)

💎 Ruby SMTP mock - flexible Ruby wrapper over [`smtpmock`](https://github.com/mocktools/go-smtp-mock). Mimic any 📤 SMTP server behavior for your test environment and even more.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Dependency manager](#dependency-manager)
    - [Available flags](#available-flags)
  - [DSL](#dsl)
    - [Available server options](#available-server-options)
    - [Example of usage](#example-of-usage)
  - [RSpec integration](#rspec-integration)
    - [SmtpMock RSpec helper](#smtpmock-rspec-helper)
    - [SmtpMock RSpec interface](#smtpmock-rspec-interface)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)
- [Credits](#credits)
- [Versioning](#versioning)
- [Changelog](CHANGELOG.md)

## Features

- Ability to handle configurable behavior and life cycles of SMTP mock server(s)
- Dynamic/manual port assignment
- Test framework agnostic (it's PORO, so you can use it outside of `RSpec`, `Test::Unit` or `MiniTest`)
- Simple and intuitive DSL
- RSpec integration out of the box
- Includes easy system dependency manager

## Requirements

Ruby MRI 2.5.0+

## Installation

Add this line to your application's `Gemfile`:

```ruby
group :development, :test do
  gem 'smtp_mock', require: false
end
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install smtp_mock
```

Then install [`smtpmock`](https://github.com/mocktools/go-smtp-mock) as system dependency:

```bash
bundle exec smtp_mock -i ~
```

## Usage

### Dependency manager

This gem includes easy system dependency manager. Run `bundle exec smtp_mock` with options for manage `smtpmock` system dependency.

#### Available flags

| Flag | Description | Example of usage |
| --- | --- | --- |
| `-s`, `--sudo` | Run command as sudo | `bundle exec smtp_mock -s -i ~` |
| `-i`, `--install=PATH` | Install `smtpmock` to the existing path | `bundle exec smtp_mock -i ~/existent_dir` |
| `-u`, `--uninstall` | Uninstall `smtpmock` | `bundle exec smtp_mock -u` |
| `-g`, `--upgrade` | Upgrade to latest version of `smtpmock` | `bundle exec smtp_mock -g` |
| `-v`, `--version` | Prints current version of `smtpmock` | `bundle exec smtp_mock -v` |
| `-h`, `--help` | Prints help | `bundle exec smtp_mock -h` |

### DSL

#### Available server options

| Example of usage kwarg | Description |
| --- | --- |
| `host: '0.0.0.0'` | Host address where `smtpmock` will run. It's equal to 127.0.0.1 by default |
| `port: 2525` | Server port number. If not specified it will be assigned dynamically |
| `log: true` | Enables log server activity. Disabled by default |
| `session_timeout: 60` | Session timeout in seconds. It's equal to 30 seconds by default |
| `shutdown_timeout: 5` | Graceful shutdown timeout in seconds. It's equal to 1 second by default |
| `fail_fast: true` | Enables fail fast scenario. Disabled by default |
| `multiple_rcptto: true` | Enables multiple `RCPT TO` receiving scenario. Disabled by default |
| `multiple_message_receiving: true` | Enables multiple message receiving scenario. Disabled by default |
| `blacklisted_helo_domains: %w[a.com b.com]` | Blacklisted `HELO` domains |
| `blacklisted_mailfrom_emails: %w[a@a.com b@b.com]` | Blacklisted `MAIL FROM` emails |
| `blacklisted_rcptto_emails: %w[c@c.com d@d.com]` | blacklisted `RCPT TO` emails |
| `not_registered_emails: %w[e@e.com f@f.com]` | Not registered (non-existent) `RCPT TO` emails |
| `response_delay_helo: 2` | `HELO` response delay in seconds. It's equal to 0 seconds by default |
| `response_delay_mailfrom: 2` | `MAIL FROM` response delay in seconds. It's equal to 0 seconds by default |
| `response_delay_rcptto: 2` | `RCPT TO` response delay in seconds. It's equal to 0 seconds by default |
| `response_delay_data: 2` | `DATA` response delay in seconds. It's equal to 0 seconds by default |
| `response_delay_message: 2` | Message response delay in seconds. It's equal to 0 seconds by default |
| `response_delay_rset: 2` | `RSET` response delay in seconds. It's equal to 0 seconds by default |
| `response_delay_quit: 2` | `QUIT` response delay in seconds. It's equal to 0 seconds by default |
| `msg_size_limit: 42` | Message body size limit in bytes. It's equal to 10485760 bytes by default |
| `msg_greeting: 'Greeting message'` | Custom server greeting message |
| `msg_invalid_cmd: 'Invalid command message'` | Custom invalid command message |
| `msg_invalid_cmd_helo_sequence: 'Invalid command HELO sequence message'` | Custom invalid command `HELO` sequence message |
| `msg_invalid_cmd_helo_arg: 'Invalid command HELO argument message'` | Custom invalid command `HELO` argument message |
| `msg_helo_blacklisted_domain: 'Blacklisted domain message'` | Custom `HELO` blacklisted domain message |
| `msg_helo_received: 'HELO received message'` | Custom `HELO` received message |
| `msg_invalid_cmd_mailfrom_sequence: 'Invalid command MAIL FROM sequence message'` | Custom invalid command `MAIL FROM` sequence message |
| `msg_invalid_cmd_mailfrom_arg: 'Invalid command MAIL FROM argument message'` | Custom invalid command `MAIL FROM` argument message |
| `msg_mailfrom_blacklisted_email: 'Blacklisted email message'` | Custom `MAIL FROM` blacklisted email message |
| `msg_mailfrom_received: 'MAIL FROM received message'` | Custom `MAIL FROM` received message |
| `msg_invalid_cmd_rcptto_sequence: 'Invalid command RCPT TO sequence message'` | Custom invalid command `RCPT TO` sequence message |
| `msg_invalid_cmd_rcptto_arg: 'Invalid command RCPT TO argument message'` | Custom invalid command `RCPT TO` argument message |
| `msg_rcptto_not_registered_email: 'Not registered email message'` | Custom `RCPT TO` not registered email message |
| `msg_rcptto_blacklisted_email: 'Blacklisted email message'` | Custom `RCPT TO` blacklisted email message |
| `msg_rcptto_received: 'RCPT TO received message'` | Custom `RCPT TO` received message |
| `msg_invalid_cmd_data_sequence: 'Invalid command DATA sequence message'` | Custom invalid command `DATA` sequence message |
| `msg_data_received: 'DATA received message'` | Custom `DATA` received message |
| `msg_msg_size_is_too_big: 'Message size is too big'` | Custom size is too big message |
| `msg_invalid_cmd_rset_sequence: 'Invalid command RSET sequence message'` | Custom invalid command `RSET` sequence message |
| `msg_invalid_cmd_rset_arg: 'Invalid command RSET argument message'` | Custom invalid command `RSET` argument message |
| `msg_rset_received: 'RSET received message'` | Custom `RSET` received message |
| `msg_quit_cmd: 'Quit command message'` | Custom quit command message |

#### Example of usage

```ruby
# Public SmtpMock interface
# Without kwargs creates SMTP mock server with default behavior.
# A free port for server will be randomly assigned in the range
# from 49152 to 65535. Returns current smtp mock server instance
smtp_mock_server = SmtpMock.start_server(not_registered_emails: %w[user@example.com]) # => SmtpMock::Server instance

# returns current smtp mock server port
smtp_mock_server.port # => 55640

# returns current smtp mock server process identification number (PID)
smtp_mock_server.pid # => 38195

# returns current smtp mock server version
smtp_mock_server.version # => '1.5.2'

# interface for graceful shutdown current smtp mock server
smtp_mock_server.stop # => true

# interface for force shutdown current smtp mock server
smtp_mock_server.stop! # => true

# interface to check state of current smtp mock server
# returns true if server is running, otherwise returns false
smtp_mock_server.active? # => true

# returns list of running smtp mock servers
SmtpMock.running_servers # => [SmtpMock::Server instance]

# interface to stop all running smtp mock servers
SmtpMock.stop_running_servers! # => true
```

### RSpec integration

Require this either in your Gemfile or in RSpec's support scripts. So either:

```ruby
# Gemfile

group :test do
  gem 'rspec'
  gem 'smtp_mock', require: 'smtp_mock/test_framework/rspec'
end
```

or

```ruby
# spec/support/config/smtp_mock.rb

require 'smtp_mock/test_framework/rspec'
```

#### SmtpMock RSpec helper

Just add `SmtpMock::TestFramework::RSpec::Helper` if you wanna use shortcut `smtp_mock_server` for SmtpMock server instance inside of your `RSpec.describe` blocks:

```ruby
# spec/support/config/smtp_mock.rb

RSpec.configure do |config|
  config.include SmtpMock::TestFramework::RSpec::Helper
end
```

```ruby
# your awesome smtp_client_spec.rb

RSpec.describe SmtpClient do
  subject(:smtp_response) do
    described_class.call(
      host: 'localhost',
      port: smtp_mock_server.port,
      mailfrom: mailfrom,
      rcptto: rcptto,
      message: message
    )
  end

  let(:mailfrom) { 'sender@example.com' }
  let(:rcptto) { 'receiver@example.com' }
  let(:message) { 'Email message context' }
  let(:expected_response_message) { '250 Custom successful response' }

  before { smtp_mock_server(msg_msg_received: expected_response_message) }

  it do
    expect(smtp_response).to be_success
    expect(smtp_response).to have_status(expected_response_status)
    expect(smtp_response).to have_message_context(expected_response_message)
  end
end
```

#### SmtpMock RSpec interface

If you won't use `SmtpMock::TestFramework::RSpec::Helper` you can use `SmtpMock::TestFramework::RSpec::Interface` directly instead:

```ruby
SmtpMock::TestFramework::RSpec::Interface.start_server  # creates and runs SmtpMock server instance
SmtpMock::TestFramework::RSpec::Interface.stop_server!  # stops and clears current SmtpMock server instance
SmtpMock::TestFramework::RSpec::Interface.clear_server! # clears current SmtpMock server instance
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/mocktools/ruby-smtp-mock>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct. Please check the [open tickets](https://github.com/mocktools/ruby-smtp-mock/issues). Be sure to follow Contributor Code of Conduct below and our [Contributing Guidelines](CONTRIBUTING.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SmtpMock project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Credits

- [The Contributors](https://github.com/mocktools/ruby-smtp-mock/graphs/contributors) for code and awesome suggestions
- [The Stargazers](https://github.com/mocktools/ruby-smtp-mock/stargazers) for showing their support

## Versioning

SmtpMock uses [Semantic Versioning 2.0.0](https://semver.org)
