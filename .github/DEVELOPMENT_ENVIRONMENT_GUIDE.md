# Development environment guide

## Preparing

Clone `smtp_mock` repository:

```bash
git clone https://github.com/mocktools/ruby-smtp-mock.git
cd  ruby-smtp-mock
```

Configure latest Ruby environment:

```bash
echo 'ruby-3.1.1' > .ruby-version
cp .circleci/gemspec_latest smtp_mock.gemspec
```

## Commiting

Commit your changes excluding `.ruby-version`, `smtp_mock.gemspec`

```bash
git add . ':!.ruby-version' ':!smtp_mock.gemspec'
git commit -m 'Your new awesome smtp_mock feature'
```
