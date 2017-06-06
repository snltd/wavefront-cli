# Wavefront CLI [![Build Status](https://travis-ci.org/snltd/wavefront-cli.svg?branch=master)](https://travis-ci.org/snltd/wavefront-cli) [![Code Climate](https://codeclimate.com/github/snltd/wavefront-cli/badges/gpa.svg)](https://codeclimate.com/github/snltd/wavefront-cli) [![Issue Count](https://codeclimate.com/github/snltd/wavefront-cli/badges/issue_count.svg)](https://codeclimate.com/github/snltd/wavefront-cli) [![Known Vulnerabilities](https://snyk.io/test/github/snltd/wavefront-cli/badge.svg)](https://snyk.io/test/github/snltd/wavefront-cli)


This package provides a command-line interface to Wavefront's API. Each API path
is covered by a different command keyword.

It is built on [the Wavefront Ruby
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

### Credentials and the Config File

You can pass in your Wavefront API and token with command-line options `-E` and
`-t`; with the environment variables `WAVEFRONT_ENDPOINT` and `WAVEFRONT_TOKEN`,
or by putting them in a configuration file at `${HOME}/.wavefront`. This is an
ini-style file, with a section for each Wavefront account you wish to use. (None
of the tokens shown here are real, of course!)

```
[default]
token = 106ba476-e3bd-c14c-4a3d-391cd4c11def
endpoint = metrics.wavefront.com
proxy = wavefront.localnet
format = human

[company]
token = 9ac40b15-f47f-a168-a5d3-271ab5bad617
endpoint = company.wavefront.com
format = yaml
```

You can override the config file location with `-c`, and select a profile with
`-P`. If you don't supply `-P`, the `default` profile is used.

### Listing Things

Most commands have a `list` subcommand, which will produce brief
"one thing per line" output. The unique ID  of the "thing" is in the first
column.

```
$ wavefront proxy list
457d6cf3-5171-45e0-8d31-5c980be889ea  test agent
917102d1-a10e-997b-ba63-95058f98d4fb  Agent on wavefront-2017-03-13-02
926dfb4c-23c6-4fb9-8c8d-833625ab8f6f  Agent on shark-wavefront
```

You can get more verbose listings with the `-l` flag.

### Describing Things

Most commands have a `describe` subcommand which will tell you more about the
object.

```
$ wavefront proxy describe 917102d1-a10e-497b-ba63-95058f98d4fb
name                     Agent on wavefront-2017-03-13-02
id                       917102d1-a10e-497b-ba63-95058f98d4fb
version                  4.7
customerId               sysdef
inTrash                  false
lastCheckInTime          2017-06-06 14:47:20
hostname                 wavefront-2017-03-13-02
timeDrift                -751
bytesLeftForBuffer       1536094720
bytesPerMinuteForBuffer  280109
localQueueSize           0
sshAgent                 false
ephemeral                false
deleted                  false
```

Most timestamps come back from the API as epoch seconds or epoch milliseconds.
The CLI, in its human-readable descriptions, will convert those to
`YYYY-MM-DD HH:mm:ss` when it `describe`s something.

### Formats, Importing, and Exporting

Most commands and sub-commands support the `-f` option. This takes one of
`json`, `yaml`, `human` and `raw`, and tells the CLI to present the information
it fetches from the Wavefront API in that format. (`raw` is the raw Ruby
representation, which, for instance, you could paste into `irb`.)

Human output can be selective. As well as the time formatting mentioned above,
human-readable listings and desctiptions may omit data which is not likely to be
useful, or which is extremely hard to present in a readable way.

If you `describe` an object like a dashboard, user, webhook etc as `json` or
`yaml`, and send the output to a file, you can re-import that data. The format of the file to be imported is automatically detected.

```
$ wavefront user list
slackboy@gmail.com
sysdef.limited@gmail.com
$ wavefront user describe -f json sysdef.limited@gmail.com > user.json
$ cat user.json
{"identifier":"sysdef.limited@gmail.com","customer":"sysdef","groups":["agent_management"]}
$ wavefront user delete sysdef.limited@gmail.com
Deleted user 'sysdef.limited@gmail.com'.
$ wavefront user list
slackboy@gmail.com
$ wavefront user import user.json
Imported user.
identifier  sysdef.limited@gmail.com
customer    sysdef
groups      agent_management
$ wavefront user list
slackboy@gmail.com
sysdef.limited@gmail.com
```

You could, of course, modify certain aspects of the exported data before
re-importing.

### Time Windows

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

## Writing Points

Writing a single point is simple:

```
$ wavefront write point cli.example 10
```

and you can add point tags, if you like.

```
$ wavefront write point cli.example 9.4 -E wavefront -T proxy=wavefront \
  -T from=README
```

or force a timestamp:

```
$ wavefront write point -t 16:53:14 cli.example 8
```

More usefully, you can write from a file. Your file must contain multiple
columns: metric name (`m`), metric value (`v`), timestamp(`t`), and point tags
(`T`). `v` is mandatory, `m` can be filled in with the `-m` flag, `t` can be
filled in with the current timestamp, and `T` is optional, but if used, must be
last. You then tell the CLI what order your fields are in.

```
$ cat datafile
1496767813 dev.cli.test 12.1
1496767813 dev.cli.test 10.0
1496767813 dev.cli.test 14.5
$ wavefront write file -F tmv datafile
```

If you set the file to `-`, you can read from standard in:

```
$ while true; do echo $RANDOM; sleep 1; done | wavefront write file -m cli.demo -Fv -
```
