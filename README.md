# Wavefront CLI

`wavefront <command> [options]`

The `wavefront` puts a CLI front-end on Wavefront's API. Each API
path is covered by a different command keyword.

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

# EVERYTHING BELOW HERE IS JUNK

In the following usage examples, the global options have been omitted
to save space.

## `ts` Mode: Retrieving Timeseries Data

The `ts` command is used to submit a standard timeseries query to
Wavefront. It can output the timeseries data in a number of formats.
You must specify a query granularity, and you can timebox your
query.

```
Usage:
  wavefront ts [-c file] [-P profile] [-E endpoint] [-t token] [-ODV]
            [-S | -m | -H | -d] [-s time] [-e time] [-f format] [-p num]
            [-X bool] <query>

Options:
  -E, --endpoint=URI            cluster endpoint [metrics.wavefront.com]
  -t, --token=TOKEN             Wavefront authentication token
  -S, --seconds                 query granularity of seconds
  -m, --minutes                 query granularity of minutes
  -H, --hours                   query granularity of hours
  -d, --days                    query granularity of days
  -s, --start=TIME              start of query window in epoch seconds or
                                strptime parseable format
  -e, --end=TIME                end of query window in epoch seconds or
                                strptime parseable format
  -f, --format=STRING           output format (raw, ruby, graphite, highcharts, human)
                                [raw]
  -p, --prefixlength=NUM        number of path elements to treat as prefix
                                in schema manipulation. [1]
  -X, --strict=BOOL             Do not return points outside the query
                                window. [true]
  -O, --includeObsoleteMetrics  include metrics unreported for > 4 weeks
```

The `-X` flag is now more-or-less obsolete. It was required when the
API defaulted to returning data outside the specified query window.

### Examples

View ethernet traffic on the host `shark`, in one-minute buckets,
starting at noon today, in human-readable format.

```
$ wavefront ts -f human -m --start=12:00 \
  'ts("lab.generic.host.interface-phys.if_packets.*", source=shark)'
query               ts("lab.generic.host.interface-phys.if_packets.*", source=shark)
timeseries          0
label               lab.generic.host.interface-phys.if_packets.tx
host                shark
2016-06-27 12:00:00 136.0
2016-06-27 12:01:00 15.666666666666668
2016-06-27 12:02:00 15.8
2016-06-27 12:03:00 15.3
2016-06-27 12:04:00 19.35
2016-06-27 12:05:00 315.451
2016-06-27 12:06:00 110.98316666666668
2016-06-27 12:07:00 34.40016666666667
2016-06-27 12:08:00 308.667
2016-06-27 12:09:00 239.05016666666666
2016-06-27 12:10:00 17.883333333333333
...
```

Show all events between 6pm and 8pm today:

```
$ ./wavefront  ts -f human -m --start=18:00 --end=20:00 'events()'
2016-06-27 16:55:59 -> 2016-06-27 16:56:40 (41s)                             new event                 [shark,box]
2016-06-27 18:41:57 -> 2016-06-27 18:41:57 (inst)    info    alert-updated   Alert Edited: Point Rate
2016-06-27 18:42:03 -> 2016-06-27 18:44:09 (2m 6s)   severe  alert           Point Rate                []
2016-06-27 18:44:09 -> 2016-06-27 18:44:09 (inst)    info    alert-updated   Alert Edited: Point Rate
2016-06-27 18:46:33 -> 2016-06-27 18:46:33 (inst)                            instantaneous_event       [box]
2016-06-27 18:47:53 -> 2016-06-27 18:47:53 (inst)                            instantaneous_event       [box] something important just happened
2016-06-27 19:25:16 -> 2016-06-27 19:26:32 (1m 15s)  info                    puppet_run                [box] Puppet run
```

Output is different for event queries.  The columns are: start time -> end
time, (duration), severity, event type, [source(s)], details.

## `alerts` Mode: Retrieving and Importing Alert Data

The `alerts` command lets you view, export, and import alerts. It
does not currently modification removal, or reacting to alerts, as
these actions are not supported by the v1 API.

Alerts can be presented in a number of formats, but defaults to a
human-readable form. If you wish to parse the output, please use the
`ruby`, `yaml` or `json` formatters.

```
Usage:
  wavefront alerts [-DnV] [-c file] [-P profile] [-E endpoint] [-t token]
            [-f format] [-p tag] [ -s tag] <state>
  wavefront alerts export [-DnV] [-c file] [-P profile] [-E endpoint] [-t token]
            [-f format] <timestamp>
  wavefront alerts import [-DnV] [-c file] [-P profile] [-E endpoint] [-t token]
            <file>

Global options:
  -c, --config=FILE    path to configuration file [/home/rob/.wavefront]
  -P, --profile=NAME   profile in configuration file [default]
  -D, --debug          enable debug mode
  -n, --noop           don't perform API calls
  -V, --verbose        be verbose
  -h, --help           show this message

Options:
  -E, --endpoint=URI       cluster endpoint [metrics.wavefront.com]
  -t, --token=TOKEN        Wavefront authentication token
  -f, --alertformat=STRING output format (ruby, json, human, yaml)
                           []
  -p, --private=TAG        retrieve only alerts with named private tags,
                           comma delimited.
  -s, --shared=TAG         retrieve only alerts with named shared tags,
                           comma delimited.
```

When exporting an alert, you must refer to it my its millisecond
timestamp. This value is in the `created` field when you view an
alert as `json` or `YAML`, and it is shown in brackets on the
`created` line if you use `human` output.

Due to v1 API limitations, not all an alert's properties will
survive the import/export process.

Imports can only be alerted from a file. Importing from stdin is
currently unsupported.

### Examples

List all alerts in human-readable format. Alerts are separated by a
single blank line.

```
$ wavefront alerts -P sysdef all
name                  over memory cap
created               2016-06-06 13:35:32 +0100
severity              SMOKE
condition             deriv(ts("prod.www.host.tenant.memory_cap.nover")) > 0
displayExpression     ts("prod.www.host.tenant.memory_cap.nover")
minutes               2
resolveAfterMinutes   10
updated               2016-06-06 13:35:32 +0100
alertStates           CHECKING
metricsUsed
hostsUsed
additionalInformation A process has pushed the instance over its memory cap.
                      That is, the `memory_cap:nover` counter has been
                      incremented. Check memory pressure.

name                  JPC Memory Shortage
created               2016-05-16 16:49:20 +0100
severity              WARN
...
```

Show alerts currently firing, in JSON format:

```
$ wavefront alerts -P sysdef --format json active
"[{\"customerTagsWithCounts\":{},\"userTagsWithCounts\":{},\"created\":1459508340708,\"name\":\"Point Rate\",\"conditionQBEnabled\":false,\"displayExpressionQBEnabled\":false,\"condition\":\"sum(deriv(ts(~collector.points.valid))) > 50000\",\"displayExpression\":\"sum(deriv(ts(~collector.points.valid)))\",\"minutes\":5,\"target\":\"alerts@company.com,\",\"event\":{\"name\":\"Point Rate\",\"startTime\":1467049323203,\"annotations\":{\"severity\":\"severe\",\"type\":\"alert\",\"created\":\"1459508340708\",\"target\":\"alerts@company.com,\"},\"hosts\":[\"\"],\"table\":\"sysdef\"},\"failingHostLabelPairs\":[{\"label\":\"\",\"observed\":5,\"firing\":5}],\"updated\":1467049317802,\"severity\":\"SEVERE\",\"additionalInformation\":\"We have exceeded our agreed point rate.\",\"activeMaintenanceWindows\":[],\"inMaintenanceHostLabelPairs\":[],\"prefiringHostLabelPairs\":[],\"alertStates\":[\"ACTIVE\"],\"inTrash\":false,\"numMetricsUsed\":1,\"numHostsUsed\":1}]"
```

Export an alert from your default account, in JSON format:

```
$ wavefront alerts export -f json 1488995981076 >my_alert.json
```

and re-import it:

```
$ wavefront alerts import my_alert.json
Alert imported.
```

## `event` Mode: Opening and Closing Events

The `event` command is used to open and close Wavefront events.

```
Usage:
  wavefront event create [-DV] [-c file] [-P profile] [-E endpoint] [-t token]
           [-d description] [-s time] [-i | -e time] [-l level] [-T type]
           [-H host] [-n] <event>
  wavefront event close [-DV] [-c file] [-P profile] [-E endpoint] [-t token]
           [<event>] [<timestamp>]
  wavefront event delete [-DV] [-c file] [-P profile] [-E endpoint] [-t token]
           <timestamp> <event>
  wavefront event show
  wavefront event --help

Options:
  -E, --endpoint=URI   cluster endpoint [metrics.wavefront.com]
  -t, --token=TOKEN    Wavefront authentication token
  -i, --instant        create an instantaneous event
  -s, --start=TIME     time at which event begins
  -e, --end=TIME       time at which event ends
  -l, --level=LEVEL    level of event (info, smoke, warn, severe)
  -T, --type=TYPE      type of event
  -d, --desc=STRING    description of event
  -H, --host=STRING    list of hosts to tag with event (comma separated)
  -n, --nostate        do not create a local file recording the event

View events in detail using the 'ts' command with the 'events()' function.
```

To close an event in the Wavefront API it must be identified by its
name and the millisecond time at which it was opened. This
information is returned when the event is opened, and the
`wavefront` command provides a handy way of caching it locally.

When a non-instantaneous event is opened and no end time is
specified, the CLI will write a file to
`/var/tmp/wavefront/event/<username>`. The name of the file
is the time the event was opened followed by `::`, followed by the
name of the event. Consider the `event/` directory as a stack:
a newly opened event is "pushed" onto the "stack". Running
`wavefront event close` simply pops the last event off the stack and
closes it. You can be more specific by running `wavefront event
close <name>`, which will close the last event opened and called `name`.

You can also specify the open-time when closing and event, bypassing
the local caching mechanism altogether.

When deleting an event you must supply the timestamp in epoch-milliseconds.
This level of precision is required by Wavefront's API, and it is
troublesome for the user to supply millisecond-accurate timestamps in any
other format.

The `wavefront event show` command lists the cached events. To
properly query events, use the `events()` command in a `ts` query.

### Examples

Create an instantaneous alert, bound only to the host making the API
call. Show the data returned by Wavefront.

```
$ wavefront event create -d "something important just happened" -i \
  -V instantaneous_event
{
  "name": "instantaneous_event",
  "startTime": 1467049673400,
  "endTime": 1467049673401,
  "annotations": {
    "details": "something important just happened"
  },
  "hosts": [
    "box"
  ],
  "isUserEvent": true,
  "table": "sysdef"
}
```

Mark a Puppet run by opening an event of `info` level, to be closed
when the run finishes.

```
$ ./wavefront event create -P sysdef -d 'Puppet run' -l info puppet_run
Event state recorded at /var/tmp/wavefront/events/rob/1467051916712::puppet_run.
```

The run has finished, close the event.

```
$ wavefront event close puppet_run
Closing event 'puppet_run'. [2016-06-27 19:25:16 +0100]
Removing state file /var/tmp/wavefront/events/rob/1467051916712::puppet_run.
```

Delete an event created in error.

```
$ wavefront delete 1476187357169 some_event
```

## `write` Mode: Sending Points to Wavefront

The `write` command is used to put data points into Wavefront. It is
different from other commands in that it communicates with a
**proxy** rather than with the Wavefront API. This means it does
not require any credentials.

```
Usage:
  wavefront write point [-DV] [-c file] [-P profile] [-E proxy] [-t time]
           [-p port] [-H host] [-n] [-T tag...] <metric> <value>
  wavefront write file [-DV] [-c file] [-P profile] [-E proxy] [-H host]
           [-p port] [-n] [-F format] [-m metric] [-T tag...] <file>
  wavefront write --help

Global options:
  -c, --config=FILE    path to configuration file [/home/rob/.wavefront]
  -P, --profile=NAME   profile in configuration file [default]
  -D, --debug          enable debug mode
  -V, --verbose        be verbose
  -h, --help           show this message

Options:
  -E, --proxy=URI            proxy endpoint [wavefront]
  -t, --time=TIME            time of data point (omit to use current time)
  -H, --host=STRING          source host [box]
  -p, --port=INT             Wavefront proxy port [2878]
  -T, --tag=TAG              point tag in key=value form
  -F, --infileformat=STRING  format of input file or stdin [tmv]
  -n, --noop                 show the metric without sending it
  -m, --metric=STRING        the metric path to which contents of a
                             file will be assigned. If the file
                             contains a metric name, the two will be
                             concatenated

Files are whitespace separated, and fields can be defined with the -F
option.  Use 't' for timestamp; 'm' for metric name; 'v' for value
and 'T' for tags. Put 'T' last.
```

`write` has two sub-commands: `write point` and `write file`. Both
allow you to specify the proxy address and port either with
command-line switches, or by the `proxy` and `port` values in your
`.wavefront` file.

### `write point`

This provides a very quick method of putting a point into Wavefront.
It takes two mandatory arguments: the metric path, and the metric
value.

You can optionally add point tags with multiple uses of `-T
key=val`, and specify a timestamp with the `-t` option.

### `write file`

`write file` takes a whitespace-separated file, and turns it into a
series of points, which it sends to a Wavefront proxy. Each line
will be mapped to a single point.

Each line in the file must be of the same format, and must contain a
value. It can optionally contain metric path, a timestamp, and point
tags. The format of the file is passed in with the `-F` option, and
it must contain only the letters `t` (timestamp), `m` (metric path),
`v` (value) and `T` (point tags). If `T` is used, it must come
last: this allows you to have as many point tags as you like, and
you do not have to have the same number for each point.

The metric can also be, to some extent, described by options. If you
do not have a metric path in the file, you can use `-m` to supply a
path to which every point will be assigned. If you use `-m` *and* a
field in the file, the two will be concatenated, with `-m` used as a
global prefix.

Similarly, a global timestamp can be supplied with `-t` (timestamps
in files must be in epoch seconds, but `-t` can be any `strptime()`
parseable string), and global point tags with one or more `-T
key=val`s. If you supply tags with `-T` and in the file, the points
will get both.

The input file does not have to be on disk: following the Unix
convention, you can use `-` as the filename, and `wavefront` will
read from standard in, converting lines to points as it receives
them. All the same rules apply as with standard files.

`wavefront write file` takes some efforts to protect the user from
sending bad data. It will not allow metrics with less than two
components, and it will not permit timestamps prior to 2000-01-01,
or more than a year in the future. It also checks that every
potential data point conforms to the limits described in the
Wavefront wire format documentation.

### Examples

Tell Wavefront that the value of `dev.myvalue` at this moment is
123.

```
$ wavefront write point dev.myvalue 123
```

Write a file of retrospective data, whwere the fields are, in order,
a timestamp, the metric path, and the value. Tag all points with
`mytag` set to `my value`.

```
$ wavefront write file -F tmvT -T mytag="my value" datafile
```

The command `parabola.rb` prints a timestamp and a 'y' value every
second. Plot the parabola in Wavefront.

```
$ parabola.rb | wavefront write file -F tv -m cli.demo.parabola -
```

## `sources` Mode: Tagging and Describing

This command is used to add tags and descriptions to Wavefront
sources. Note that source tags are not the same as point tags.

```
Usage:
  wavefront source list [-c file] [-P profile] [-E endpoint] [-t token] [-DV]
           [-f format] [-T tag ...] [-ag] [-s source] [-l limit] <pattern>
  wavefront source show [-c file] [-P profile] [-E endpoint] [-t token] [-DV]
           [-f format] <host> ...
  wavefront source describe [-c file] [-P profile] [-E endpoint] [-t token]
           [-DV] [-H host ... ] <description>
  wavefront source undescribe [-c file] [-P profile] [-E endpoint] [-t token]
           [-DV] [<host>] ...
  wavefront source tag add [-c file] [-P profile] [-E endpoint] [-t token]
           [-DV] [-H host ... ] <tag> ...
  wavefront source tag delete [-c file] [-P profile] [-E endpoint] [-t token]
           [-DV] [-H host ... ] <tag> ...
  wavefront source untag [-c file] [-P profile] [-E endpoint] [-t token] [-DV]
           [<host>] ...
  wavefront source --help

Options:
  -E, --endpoint=URI        cluster endpoint [metrics.wavefront.com]
  -t, --token=TOKEN         Wavefront authentication token
  -a, --all                 including hidden sources in 'human' output
  -g, --tags                show tag counts in 'human' output
  -T, --tagged=STRING       only list sources with this tag when using
                            'human' output
  -s, --start=STRING        start the list after the named source
  -l, --limit=NUMBER        only list NUMBER sources
  -H, --host=STRING         source to manipulate
  -f, --sourceformat=STRING output format (ruby, json, human)
                            [human]
```

Tags and descriptions can be applied to multiple sources by repeated
`-H` options. If no source name is supplied, `wavefront` will use
the name of the local machine, as supplied by Ruby's
`Socket.gethostname` method.

The `<pattern>` argument in to the `source list` works as a
substring match. So `pie` will match `pie`, `pier`, `timepieces`,
etc. Regular expressions will not work.

### Examples

List, in human-readable format, all active (non-hidden) sources whose name
contains `cassandra`, which are tagged with `prod` and `eu-west-1`.

```
$ wavefront source list -T prod -T eu-west-1 -f human cassandra
```

Tag this host with `dev` and the kernel version:

```
$ wavefront tag add dev $(uname -r)
```

Remove all the tags from `i-123456` and `i-abcdef`

```
$ wavefront source untag i-123456 i-abcdef
```

Get the description and tags for the host `build-001`, in JSON format.

```
$ wavefront source show -f json build-001 | json
{
  "hostname": "build-001",
  "userTags": [
    "JPC",
    "SmartOS",
    "dev"
  ],
  "description": "build server"
}
```

Get a human-readable summary of all the source tags in Wavefront. This works by giving a source name pattern that won't match anything.

```
$ wavefront source list -t '^$'
HOSTNAME                  DESCRIPTION                    TAGS

TAG                      COUNT
hidden                   339
physical                 10
zone                     363
```

## `dashboard` Mode:

The `dashboard` command implements all of the v1 API's `dashboard`
paths.

```
Usage:
  wavefront dashboard list [-DnV] [-c file] [-P profile] [-E endpoint]
           [-f format] [-t token] [-T tag...] [-p tag...] [-a]
  wavefront dashboard import [-DnV] [-c file] [-P profile] [-E endpoint]
           [-f format] [-F] <file>
  wavefront dashboard export [-DnV] [-c file] [-P profile] [-E endpoint]
           [-f format] [-v version] <dashboard_id>
  wavefront dashboard create [-DnV] [-c file] [-P profile] [-E endpoint]
           <dashboard_id> <name>
  wavefront dashboard clone [-DnV] [-c file] [-P profile] [-E endpoint]
           [-v version] -s source_id <new_id> <new_name>
  wavefront dashboard delete [-DnV] [-c file] [-P profile] [-E endpoint]
           <dashboard_id>
  wavefront dashboard undelete [-DnV] [-c file] [-P profile] [-E endpoint]
           <dashboard_id>
  wavefront dashboard history [-DnV] [-c file] [-P profile] [-E endpoint]
           [-f format] [-S version] [-L limit] <dashboard_id>
```

Dashboard IDs are the same as their `url` fields when listed or exported.

Deleting a dashboard once will move it to "trash". Deleting a second
time removes it for ever. Dashboards can be recovered from the trash
with the `undelete` command.

Listing dashboards with `-f human` will not ordinarily display
dashboards in the trash. Supplying the `-a` option will list all
dashboards, and trashed ones will have `(in trash)` appended to
their name field. Listing dashboards in a machine-parseable format
does not do this filtering.

When cloning a dashboard you may use the `-v` flag to clone from a
specific version. Without `-v` the current dashboard is cloned.

If your dashboard output format, defined either by the `-f` flag or
the `dashformat` config-file setting is `human`, and you use
`dashboard export`, the output format will silently switch to JSON
for that one command.

Importing a dashboard will fail if a dashboard with the same url
already exists. If  you supply the `-F` flag, the existing dashboard
will be overwritten.

Dashboards can be imported from YAML or JSON files, but not
currently from standard in. The file format is automatically
detected.

### Examples

List active dashboards in a human-readable form:

```
$ wavefront dashboard list -f human
ID                               NAME
S3                               S3
box                              how busy is box?
discogs                          discogs data
internal_metrics                 Internal Metrics
intro-anomaly-detection-series-1 Intro: Use Case: Anomaly Detection
Series - Part 1
intro-code-push-example          Intro: Use Case: Code Push Event
...
```

Show the modification history of a dashboard, in human-readable
form:

```
$ wavefront dashboard history shark-overview
25  2016-10-01 16:08:29 +0100 (slackboy@gmail.com)
      Dashboard Section: Incoming Chart added
      Chart: swapping events in Section: Memory updated
24  2016-10-01 16:06:25 +0100 (slackboy@gmail.com)
      Chart: swapping events in Section: Memory updated
23  2016-10-01 15:35:39 +0100 (slackboy@gmail.com)
      Chart: SMF services added to Section: System Health
      Chart: ZFS ARC in Section: ZFS updated
22  2016-10-01 15:31:18 +0100 (slackboy@gmail.com)
      Chart: ZFS ARC in Section: ZFS updated
21  2016-10-01 15:30:57 +0100 (slackboy@gmail.com)
      Dashboard Section: Incoming Chart removed
      Dashboard Section: Memory added
      Dashboard Section: Memory added
20  2016-10-01 15:30:07 +0100 (slackboy@gmail.com)
      Chart: swapping events added to Section: Incoming Chart
19  2016-10-01 15:25:40 +0100 (slackboy@gmail.com)
      Dashboard Section: Incoming Chart added
      Chart: ZFS ARC in Section: ZFS updated
...
```

The first column is the version of the dashboard.

Export a dashboard to a JSON file

```
$ wavefront dashboard export -f json shark-overview >shark_overview.json
```

And import it back in
```
$ wavefront dashboard import shark_overview.json
```

### Caveats

It is not currently possible to delete the example dashboards
supplied by Wavefront. This is not the fault of the CLI or SDK.

## Notes on Options

### Default Configuration

Passing tokens and endpoints into the `wavefront` command can become
tiresome, so you can put such data into an `ini`-style configuration
file. By default this file should be located at `${HOME}/.wavefront`,
though you can override the location with the `-c` flag. You can
also put a system-wide file at `/etc/wavefront/client.conf`, though
the user-specific file will take precedentce.

You can switch between Wavefront accounts using profile stanzas,
selected with the `-P` option.  If `-P` is not supplied, the
`default` profile will be used. Not having a useable configuration
file will not cause an error.

A configuration file looks like this:

```
[default]
token = abcdefab-1234-abcd-1234-abcdefabcdef
endpoint = companya.wavefront.com
format = json
alertformat = human

[companyb]
token = 12345678-abcd-0123-abcd-123456789abc
endpoint = metrics.wavefront.com
proxy = wavefront.local
sourceformat = json
```

The key for each key-value pair can match any long option show in the
command `help`, so you can set, for instance, a default output
format for timeseries, alerts and source commands, as shown above.

If an option is defined by a command-line switch, and in the
configuration file, the config file will win.
