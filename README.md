# Wavefront CLI

[![Test](https://github.com/snltd/wavefront-cli/actions/workflows/test.yml/badge.svg)](https://github.com/snltd/wavefront-cli/actions/workflows/test.yml)
[![Release](https://github.com/snltd/wavefront-cli/actions/workflows/release.yml/badge.svg)](https://github.com/snltd/wavefront-cli/actions/workflows/release.yml)
[![Gem Version](https://badge.fury.io/rb/wavefront-cli.svg)](https://badge.fury.io/rb/wavefront-cli)
![](http://ruby-gem-downloads-badge.herokuapp.com/wavefront-cli?type=total)

This is a complete command-line interface to
[Tanzu Observability](https://www.broadcom.com/products/software/aiops-observability/tanzu-observability),
formerly known as Wavefront. Throughout this document it will be referred to by
its old name.

As well as covering the Wavefront API, the CLI also makes it easy to get data
into Wavefront from the command-line.

The gem is hosted [on Rubygems](https://rubygems.org/gems/wavefront-cli) and can
be installed with

```
$ gem install wavefront-cli
```

It is built on my [Wavefront Ruby SDK](https://github.com/snltd/wavefront-sdk)
and requires Ruby >= 3.1. It has no "native extension" dependencies.

For a far more comprehensive overview/tutorial, please read
[this article](https://tech.id264.net/article/wavefront-cli).

```
Wavefront CLI

Usage:
  wf command [options]
  wf --version
  wf --help

Commands:
  account            view and manage Wavefront accounts
  alert              view and manage alerts
  apitoken           view and your own API tokens
  cloudintegration   view and manage cloud integrations
  config             create and manage local configuration, and display debug info
  dashboard          view and manage dashboards
  derivedmetric      view and manage derived metrics
  event              open, close, view, and manage events
  ingestionpolicy    view and manage ingestion policies
  integration        view and manage Wavefront integrations
  link               view and manage external links
  message            read and mark user messages
  metric             get metric details
  metricspolicy      view and manage metrics policies
  notificant         view and manage Wavefront alert targets
  proxy              view and manage proxies
  query              run Wavefront queries
  role               view and manage roles
  savedsearch        view and manage saved searches
  serviceaccount     view and manage service accounts
  settings           view and manage system preferences
  source             view and manage source tags and descriptions
  spy                monitor traffic going into Wavefront
  usage              view and manage usage reports
  usergroup          view and manage Wavefront user groups
  webhook            view and manage webhooks
  window             view and manage maintenance windows
  write              send data to Wavefront

Use 'wf <command> --help' for further information.
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

Most commands have a `list` subcommand, which will produce brief "one thing per
line" output. The unique ID of the "thing" is in the first column.

```
$ wf proxy list
457d6cf3-5171-45e0-8d31-5c980be889ea  test agent
917102d1-a10e-997b-ba63-95058f98d4fb  Agent on wavefront-2017-03-13-02
926dfb4c-23c6-4fb9-8c8d-833625ab8f6f  Agent on shark-wavefront
```

You can get more verbose listings with the `-l` flag. Results may be paginated.
You can progress through pages with the `-L` and `-o` options, or use `--all` to
get everything in one go.

### Describing Things

Most commands have a `describe` subcommand which will tell you more about the
object.

```
$ wf proxy describe 917102d1-a10e-497b-ba63-95058f98d4fb
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

All commands support the `-f` option. This takes one of `json`, `yaml`, `human`
and `raw`, and tells the CLI to present the information it fetches from the
Wavefront API in that format. (`raw` is the raw Ruby representation, which, for
instance, you could paste into `irb`.) Some object types can be exported in
other formats. Alerts, notificants and dashboards can be exported as HCL, for
easy integration with
[Space Ape's Wavefront Terraform
provider](https://tech.spaceapegames.com/2017/09/28/building-a-custom-terraform-provider-for-wavefront/).
Query results can be presented as CSV files, or in the native Wavefront data
format.

Human output can be selective. As well as the time formatting mentioned above,
human-readable listings and desctiptions may omit data which is not likely to be
useful, or which is extremely hard to present in a readable way.

If you `describe` an object like a dashboard, account, webhook etc as `json` or
`yaml`, and send the output to a file, you can re-import that data. The format
of the file to be imported is automatically detected.

```
$ wf user list
slackboy@gmail.com
sysdef.limited@gmail.com
$ wf user describe -f json sysdef.limited@gmail.com > user.json
$ cat user.json
{"identifier":"sysdef.limited@gmail.com","customer":"sysdef","groups":["agent_management"]}
$ wf user delete sysdef.limited@gmail.com
Deleted user 'sysdef.limited@gmail.com'.
$ wf user list
slackboy@gmail.com
$ wf user import user.json
Imported user.
identifier  sysdef.limited@gmail.com
customer    sysdef
groups      agent_management
$ wf user list
slackboy@gmail.com
sysdef.limited@gmail.com
```

You could, of course, modify certain aspects of the exported data before
re-importing. You can import an object over the top of an existing one with
`import --update`.

### Time Windows

Commands which operate on a time window, such as `query` or `event` will expect
that window to be defined with `-s` and `-e` (or `--start` and `--end`). Times
can be in seconds since the epoch, or any format which
[Ruby's `strptime` method](https://ruby-doc.org/stdlib-2.3.1/libdoc/date/rdoc/DateTime.html#method-c-strptime)
method can parse unaided. For instance:

```
$ wf command --start 12:15 --end 12:20 ...
```

will define a window between 12:15 and 12:20pm today. If you ran that in the
morning, the time would be invalid, and you would get a 400 error from
Wavefront, so something of the form `2016-04-17T12:25:00` would remove all
ambiguity.

There is no need to include a timezone in your time: the `wf` CLI will
automatically use your local timezone when it parses the string. You can also
specify relative times: for instance '-10m' for the last ten minutes.

## Querying Data

Use the `query` subcommand with any timeseries expression.

```
$ wf query "ts(cpu.*.pc.user, source=cube)" | more
name          ts(cpu.*.pc.user, source=cube)
query         ts(cpu.*.pc.user, source=cube)
timeseries
  label       cpu.0.pc.user
  sparkline   > ▇▅     █<
  host        cube
  tags
    env       lab
  data                     13:39:00    26.081756828668336
                           13:40:00    20.37380923087
                           13:41:00    4.086552186471667
                           13:42:00    2.5642049289966664
                           13:43:00    2.542284133615
                           13:44:00    2.6524157880366666
                           13:45:00    2.1158611431600005
                           13:46:00    27.911804005566665
              2019-03-07   13:38:00    3.8412758439216668
              ------------------------------------------------------------------
  label       cpu.1.pc.user
  sparkline   > █▅     ▇<
  host        cube
  tags
    env       lab
  data                     13:39:00    27.45281202666833
                           13:40:00    19.441659754188333
                           13:41:00    3.96397654233
                           13:42:00    2.49657063456
                           13:43:00    2.4946187951783334
                           13:44:00    2.8966526517783335
                           13:45:00    2.636301021795
                           13:46:00    25.407542657531668
              2019-03-07   13:38:00    4.655340261835
...
events        <none>
warnings      <none>
```

By default you get the last ten minutes of data, but the time windowing rules
can be used to specify any range.

## Writing Points

Writing a single point is simple:

```
$ wf write point cli.example 10
```

and you can add point tags, if you like.

```
$ wf write point cli.example 9.4 -E wavefront -T proxy=wavefront -T from=README
```

or force a timestamp:

```
$ wf write point -t 16:53:14 cli.example 8
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
$ wf write file -F tmv datafile
```

If you set the file to `-`, you can read from standard in:

```
$ while true; do echo $RANDOM; sleep 1; done | wf write file -m cli.demo -Fv -
```

If you wish to write points directly via the API, and you have the "direct
ingestion" privilege, just add `-u api` to your `write` command. To send points
to a proxy over HTTP, use `-u http`, and to write to a Unix socket use
`-u socket`.

You can write delta metrics with `-i` (for increment).

```
$ wf write point -i counter.example 4
```

To sent negative values, you must use `--` to tell `wf` that you have finished
declaring options, or get creative with your quoting.

```
$ wf write point cli.example -- -10
$ wf write point cli.example "\-10"
```

You can even write distributions. Either list every number individually, or use
`x` to specify multiples of any value. You can mix and match within the same
line.

```
$ wf write distribution dist.example 3 1 4 1 1 2 3 6 4 1 3 2
$ wf write distribution dist.example 3x3 4x1 2x4 2x2 1x6
$ wf write distribution dist.example 3x3 4x1 4 4 2x2 6
```
