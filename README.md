# UCCMe App

Web application for sharing documents with specific individuals using Creative Commons defined by the author.

Please also note the Web API that it uses: https://github.com/SEC-GammaRay/UCCMe-api

## Install

Install this application by cloning the *relevant branch* and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test specification script in `Rakefile`:

```
rake spec
```

## Execute

Launch the application using:

```shell
rake run:dev
```

The application expects the API application to also be running (see `config/secrets_example.yml` for specifying its URL)

## Release Check
Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):

```
rake release?
```