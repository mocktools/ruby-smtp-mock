# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.3] - 2023-01-10

### Added

- Added and tested Ruby 3.2.x support
- Added `changeloglint`

### Updated

- Updated `CircleCI` config
- Updated `lefthook`/`codeclimate`/`simplecov`/`pry` configs
- Updated gem deploy flow (tagging new release on master merge commit)
- Updated gem version, license

## [1.3.2] - 2022-12-12

### Added

- Added [`cspell`](https://cspell.org) linter
- Added [`markdownlint`](https://github.com/DavidAnson/markdownlint) linter
- Added [`shellcheck`](https://www.shellcheck.net) linter
- Added [`yamllint`](https://yamllint.readthedocs.io) linter

### Fixed

- Fixed typos in project's codebase
- Fixed new project's linter issues

### Updated

- Updated `CircleCI` config
- Updated [`lefthook`](https://github.com/evilmartians/lefthook) linters aggregator config
- Updated releasing script, gemspecs
- Updated gem version

## [1.3.1] - 2022-12-01

### Added

- Added new bunch of project linters
- Added auto deploy to RubyGems
- Added auto creating release notes on GitHub

### Updated

- Updated gemspecs
- Updated `codeclimate`/`circleci` configs
- Updated gem development dependencies
- Updated gem version

### Removed

- Removed `overcommit` dependency

## [1.3.0] - 2022-11-19

### Added

- Added ability to configure multiple `RCPT TO` receiving scenario

### Updated

- Updated `SmtpMock::Types::Bool`, tests
- Updated `codeclimate`/`circleci` configs
- Updated gemspecs
- Updated gem runtime/development dependencies
- Updated gem documentation, version

## [1.2.2] - 2022-10-05

### Fixed

- Fixed wrong semantic version comparison in `SmtpMock::Dependency#minimal_version?`

### Updated

- Updated gemspecs
- Updated tests
- Updated `codeclimate`/`circleci` configs
- Updated gem development dependencies
- Updated gem version

## [1.2.1] - 2022-07-27

### Fixed

- Fixed documentation

### Updated

- Updated gem documentation, version

## [1.2.0] - 2022-07-27

### Added

- Added ability to use `RSET` SMTP command
- Added ability to configure multiple message receiving flow during one session
- Added ability to configure SMTP command delay responses

### Updated

- Updated gemspecs
- Updated tests
- Updated `rubocop`/`codeclimate`/`circleci` configs
- Updated gem development dependencies
- Updated gem documentation, version

## [1.1.0] - 2022-05-17

### Added

- Ability to check `smtpmock` version from cli

### Updated

- Updated gemspecs
- Updated `codeclimate`/`circleci` configs
- Updated gem development dependencies
- Updated gem version

## [1.0.1] - 2022-03-10

### Added

- Development environment guide

### Updated

- Updated gemspecs
- Updated `codeclimate`/`circleci` configs
- Updated gem development dependencies
- Updated gem version

## [1.0.0] - 2022-01-31

### Added

- Added `smtpmock` version checker
- Added command for upgrade `smtpmock` to latest version
- Added `SmtpMock::Error::Dependency::SMTPMOCK_MIN_VERSION`
- Added `SmtpMock::Server#version`, tests

### Updated

- Updated `SmtpMock::Dependency.verify_dependencies`, tests
- Updated `SmtpMock::Cli::Command`, tests
- Updated gem version, documentation

## [0.1.2] - 2022-01-24

### Updated

- Updated `SmtpMock::Cli::Command`, tests
- Updated gem version, documentation

## [0.1.1] - 2022-01-18

### Updated

- Updated gem documentation
- Updated `codeclimate` config

## [0.1.0] - 2022-01-18

### Added

- First release of `SmtpMock`. Thanks [@le0pard](https://github.com/le0pard) for support 🚀
