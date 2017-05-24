# Wavefront CLI [![Code Climate](https://codeclimate.com/github/snltd/wavefront-cli/badges/gpa.svg)](https://codeclimate.com/github/snltd/wavefront-cli) [![Issue Count](https://codeclimate.com/github/snltd/wavefront-cli/badges/issue_count.svg)](https://codeclimate.com/github/snltd/wavefront-cli) [![Known Vulnerabilities](https://snyk.io/test/github/snltd/wavefront-cli/badge.svg)](https://snyk.io/test/github/snltd/wavefront-cli)


This package provides a simple CLI front-end for Wavefront's API. Each API path
is covered by a different command keyword.

It is built on [my Wavefront
SDK](https://github.com/snltd/wavefront-sdk) and requires Ruby >= 2.2.

```
$ wavefront --help
Wavefront CLI

Usage:
  wavefront [options] command [options]
  wavefront --version
  wavefront --help

Commands:
  alert         view and manage alerts
  integration   view and manage cloud integrations
  dashboard     view and manage dashboards
  event         view, manage, open, and close events
  link          view and manage external links
  message       view and mark as read user messages
  metric        view metric details
  proxy         view and manage Wavefront proxies
  query         run timeseries queries
  savedsearch   view and manage saved searches
  source        view and manage source tags and descriptions
  user          view and manage Wavefront users
  window        view and manage maintenance windows
  webhook       view and manage webhooks
  write         send data points to a Wavefront proxy

Use 'wavefront <command> --help' for further information.
```

## General Rules

Most commands have a `list` subcommand, which will produce brief
"one thing per line" output with the `-b` (or `--brief`) flag.

```
$ wavefront proxy list -b
457d6cf3-5171-45e0-8d31-5c980be889ea  test agent
917102d1-a10e-997b-ba63-95058f98d4fb  Agent on wavefront-2017-03-13-02
926dfb4c-23c6-4fb9-8c8d-833625ab8f6f  Agent on shark-wavefront
```

Commands which operate on a time window, such as `query` or `event`
will expect that window to be defined with `-s` and `-e` (or
`--start` and `--end`). Times can be in seconds since the epoch, or
any format which [Ruby's `strptime`
method](https://ruby-doc.org/stdlib-2.3.1/libdoc/date/rdoc/DateTime.html#method-c-strptime)
method can parse unaided. For instance:

```
$ wavefront --start 12:15 --end 12:20 ...
```

will define a window between 12:15 and 12:20pm today. If you ran
that in the morning, the time would be invalid, and you would get a
400 error from Wavefront, so something of the form
`2016-04-17T12:25:00` would remove all ambiguity.

There is no need to include a timezone in your time: the `wavefront`
CLI will automatically use your local timezone when it parses the
string.

The following options are valid in almost all contexts.

```
-c, --config=FILE    path to configuration file [default: ~/.wavefront]
-P, --profile=NAME   profile in configuration file [default: default]
-D, --debug          enable debug mode
-V, --verbose        enable verbose mode
-h, --help           show help for command
```

Debug mode will show you combined options, and debug output from
`faraday`. It also shows the full stack trace should a command
fail. This output can be very verbose.

