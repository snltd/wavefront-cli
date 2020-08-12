# Changelog

## 7.2.0 (2020-08-12)
* Add `cloudintegration awsid generate` command.
* Add `cloudintegration awsid delete <external_id>` command.
* Add `cloudintegration awsid validate <external_id>` command.
* Require 5.1.x of [the SDK](https://github.com/snltd/wavefront-sdk).

## 7.1.0 (2020-08-07)
* Remove `user` command. (Breaking change.)
* Add `account` command.
* Complete coverage of roles and user groups.
* Add `alert affected hosts` command to show which hosts are affected by one
  or all firing alerts.
* Remove obsolete `group` subcommands. (`grant` and `revoke`).
* Add `write noise` command to send a flow of random data to an endpoint.
* Better information when working with cloud integrations.

## 7.0.0 (unreleased)

## 6.1.0 (2020-06-02)
* Add `-A` flag to `proxy list` command, to only list active proxies

## 6.0.0 (2020-04-07)
* Remove `cluster` command. (Breaking change.)
* Add `role` command.
* Add `--nocache`, `--nostrict` and `--histogram-view` options to `query`
  command.
* Require 5.x of [the SDK](https://github.com/snltd/wavefront-sdk).

## 5.1.2 (2020-02-28)
* Fix regression in HCL dashboard export.
* Properly handle unavailable port when sending distributions to a proxy.

## 5.1.1 (2020-02-20)
* Say whether `--upsert` did an update or an import.

## 5.1.0 (2020-02-20)
* Add `-U` (`--upsert`) option to `import` sub-commands.

## 5.0.1 (2020-02-18)
* Bugfix: threshold alerts could not be imported.

## 5.0.0 (2020-02-17)
* Remove support for Ruby 2.3. (Potentially breaking change.)
* Add `cluster` command to manage monitored clusters.
* Add `spy` command to speak to (unstable) `spy` API.
* Add `metric list` sub-commands to speak to (unstable) `metric` API.
* Require 4.0.0 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 4.6.1 (2020-02-09)
* Fix bug which broke reporting of points sent via a proxy.
* Require 3.7.1 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 4.6.0 (2020-01-28)
* Add `ingestionpolicy` and `usage` commands.
* Require 3.7.x of [the SDK](https://github.com/snltd/wavefront-sdk).

## 4.5.2 (2020-01-15)
* Test build against, and fix warning messages on, Ruby 2.7.0
* Bump SDK dependency to 3.6.1

## 4.5.1 (2020-01-14)
* Bugfix. CSV query output errored on metrics without tags.

## 4.5.0 (2019-11-12)
* Add `user business functions` command.

## 4.4.2 (2019-10-31)
* Bugfix: `dashboard import --update` didn't work when reading from stdin.
* Better handling of tag values in brief listings.

## 4.4.1 (2019-10-31)
* Elegantly handle requests to print non-existent fields.

## 4.4.0 (2019-10-31)
* Add `-O fields` option to `search` subcommands.

## 4.3.1 (2019-09-30)
* Bugfix `serviceaccount` command.

## 4.3.0 (2019-09-30)
* Add `serviceaccount` command.
* Add `user privileges` command.
* Refactor of all tests, which exposed the following:
* Fix noops on `proxy versions`, `window ongoing` and `window
  pending`.
* Fix partially broken `source list` command.
* Make `source search --cursor <source>` work properly.
* Remove duplicate `manifests` subcommand from `integrations`
  command.
* Fix broken noop on `acl clear`.
* Fix `derivedmetric` and `notificant` `set` commands.
* Fix various `alert` commands when using `--noop`.
* Better handling of bad `search` input.
* Fix bug when trying to read non-existent messages.
* Fix missing quote in `usergroup delete` output.
* Fix broken `--all` in usergroup listings and searches.
* Fix `user dump`.
* Removed `user set` command, because it didn't do anything.
* Improve output of `user` and `usergroup` commands.
* Refactor of `event` command handling.
* Require 3.5.x of [the SDK](https://github.com/snltd/wavefront-sdk).

## 4.2.1 (2019-07-26)
* Remove tagging subcommands from `apitoken` command's usage info, because you
  can't tag API tokens.

## 4.2.0 (2019-07-01)
* Add `-M` (`--items-only`) option to all commands. For
  machine-parseable formats, this filters the API response, giving only
  the `items` array, which should usually be suitable for batch
  importing. This is a more sophisticated and flexible implementation of
  4.1.0's `dump` subcommand.

## 4.1.0 (2019-06-27)
* Add `dump` subcommand for all importable object types. Produces
  JSON or YAML output.
* Allow batch importing of objects. Works with files produced by
  `dump` subcommand, or by manually creating a JSON or YAML array of
  objects. Batch imports are automatically detected by the `import`
  subcommand.

## 4.0.2 (2019-06-20)
* Allow importing of dashboards which have a URL but not an ID.

## 4.0.1 (2019-06-18)
* `update` subcommand has been changed to `set`. (Breaking change.)
* `import` subcommand now accepts `--update` (`-u`) option, which
  lets you overwrite an existing object with a JSON or YAML
  description.
* Fix `tag searchpath` bug.

## 4.0.0 (2019-06-18)
* Failed push to Gemfury. Does not exist.

## 3.3.0 (2019-06-10)
* Support negation searches. Search for alerts with targets *not*
  containing `str` with `wf alert search target!~str`.
* Add `tag pathsearch` command. Searches for tags whose hierarchical
  names begin with the given element(s).
* Better printing of structured search results. For example `wf
  alert search tags=X`.
* Support freetext searches. Use `wf <object> search
  freetext=string` and you will be given a list of the objects which
  match the search along with the matching keys. (Not values!)
  Adding `-l` presents all matching objects in full.

## 3.2.3 (2019-05-24)
* Don't print erroneous pagination message when using `list --all`.
* Require 3.3.2 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 3.2.2 (2019-05-16)
* Smarter error messages.
* Require 3.3.1 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 3.2.1 (2019-05-09)
* Fix for new API ACL format.
* Require 3.3.0 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 3.2.0 (2019-04-30)
* New `apitoken` command lets you manage your own API tokens.
* Support for alert ACLs.
* Require 3.2.0 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 3.1.4 (2019-05-02)
* Fix `alert import` missing tags bug.
* Allow importing of notificants.

## 3.1.3 (2019-04-24)
* Fix `write distribution` bug. Points would be sent, but results
  could not be displayed, causing a crash unless you used `-q`.

## 3.1.2 (2019-04-06)
* Bugfix on handling of invalid config files.
* Explicitly specifying a missing config file now causes an error
  whether or not credentials available from other mechanisms.
* Require 3.0.2 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 3.1.1 (2019-04-05)
* Usernames do not have to be e-mail addresses.
* Require 3.0.1 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 3.1.0 (2019-04-02)
* Add `message read` command.

## 3.0.1 (2019-03-23)
* Fix `config about` bug.

## 3.0.0 (2019-03-23)
* Drop support for Ruby 2.2. (Potentially breaking change.)
* Remove the (deprecated) `report` command. Send points directly to
  Wavefront with `write --use api`. (Potentially breaking change.)
* Added `settings` command to view and manage system preferences.
* `dashboard` command supports new ACL mechanism.
* All commands now accept the `-f` (`--format`) option.
* New, improved `human` output. Finally fixes a very old bug where
  heavily indented columns could run into one another.
* In long listings, items with empty values now display as `<none`>
  instead of being omitted.
* Move `id` and `name` to the top of objects in long listings, for
  easier reading.
* Improved output testing
* `wf write` understands `--`, which makes it easier to send
  negative values.
* Fix ugly output when a raw query did not specify a host.
* New `config about` subcommand gives diagnostic info.
* Require 3.0.0 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 2.18.0 (2019-02-22)
* Add `usergroup` command, and extend `user` command to cover new
  RBAC features.
* Require 2.5.0 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 2.17.0 (2019-02-19)
* Add `-O field,field` to all `list` commands. This lets you select
  the fields displayed in the output.

## 2.16.2 (2018-12-29)
* Fix typo in `query` help. CSV headers are produced with `-F
  headers`, not `-F header`.

## 2.16.1 (2018-12-29)
* Fix regression which broke query time ranges.
* Fix regression which made `--noop` silent unless `--verbose` was
  also specified.
* Fix crash if `wf metric` matched no series.
* Fix bug calculating query granularity when only one end of a
  time range is specified.
* Add much more comprehensive `--noop` tests.
* Better handling of `--noop` on commands which cannot support it.

## 2.16.0 (2018-12-23)
* Add `config` command to quickly set up and manage profiles.

## 2.15.2 (2018-12-21)
* Fix bug which caused an unhandled exception if CSV or Wavefront
  query outputs tried to process an empty data set.

## 2.15.1 (2018-12-20)
* Fix bug where `alert snoozed` and `alert firing` did the same
  thing.

## 2.15.0 (2018-12-18)
* Gracefully handle ctrl-c.
* Add `install` and `uninstall` subcommands to `wf alert`.
* Add `enable` and `disable` subcommands to `wf cloudintegration`.
* Add `fav` and `unfav` commands to `wf dashboard`.
* Add `alert install`, `alert uninstall`, `installed`, and
  `manifest` commands to `wf integration`.
* Require 2.2.0 of [wavefront-sdk](https://github.com/snltd/wavefront-sdk).

## 2.14.0 (2018-12-15)
* Add `-n` to `dashboard`'s `list` and `queries` commands to omit
  system-owned dashboards.
* Let `queries` subcommand accept an optional ID.

## 2.13.0 (2018-12-11)
* Add CSV output for `query` command.
* Add multiple format outputs for all applicable `alert`
  subcommands.
* Add `queries` subcommand for `alert` and `dashboard` subcommands,
  to quickly see which queries (and therefore timeseries) are being
  used.

## 2.12.0 (2018-11-26)
* Support SDK's new `unix` writer, which lets you write points to a
  local Unix datagram socket. This requires `-u unix` and `-S
  filename`.

## 2.11.0 (2018-10-24)
* Add `proxy versions` subcommand. Lists proxies and their versions,
  newest to oldest.

## 2.10.1 (2018-10-22)
* Fix bug seen when listing events with `-s` AND `-L`.

## 2.10.0 (2018-10-22)
* Most `list` subcommands accept `-a / --all`, and will show all
  objects of the given type, with no pagination. (Exceptions are
  `user`, which never paginated because the API doesn't, and
  `source`, where the operation would take a prohibitively long
  time.)
* `search` operations also accept `-a / --all`.
* Add `window ongoing` subcommand, to show currently open
  maintenance windows.
* Add `window pending` subcommand, to show upcoming
  maintenance windows. Defaults to windows in the next 24 hours, but
  takes a decimal hour as an argument.
* Add `alert currently <state>` subcommand to list all alerts in any
  allowable state.
* Use version 2 of [wavefront-sdk](https://github.com/snltd/wavefront-sdk).
* Write
  [distributions](https://docs.wavefront.com/proxies_histograms.html)
  to a proxy. Distributions can be specified singly, or streamed
  from a file. Please see [this
  page](https://sysdef.xyz/post/2018-04-08-wavefront-writer) for
  more information.
* Add `-u / --using` option to `write` command. This lets you send
  points to proxies using alternate transport methods. At the moment
  only `-u http` is supported, but other mechanisms will be added as
  they are made available by Wavefront.
* Display local times by default, in the same way as the UI.
* Improve quality of `--verbose` output when writing points.
* Improved usage error messages.
* Use a single connection when streaming data to a proxy from STDIN.
* Don't list hidden sources unless specifically asked.

## 2.9.3 (2018-09-03)
* Fix a bug where indefinitely snoozed alerts broke `wf alert
  snoozed`.

## 2.9.2 (2018-08-22)
* Fix regression which broke the `wf` command when it ran without a
  tty.

## 2.9.1 (2018-08-22)
* Use 1.6.2 of [wavefront-sdk](https://github.com/snltd/wavefront-sdk).

## 2.9.0 (2018-08-22)
* Create external links with new `link create` sub-command.
* Fix bug which stopped you writing points without a `.wavefront`
  configuration file.
* Improved error reporting.
* Bugfix on external link searching.
* Modify external link filters.
* Use 1.6.1 of [wavefront-sdk](https://github.com/snltd/wavefront-sdk).

## 2.8.0 (2018-08-08)
* Add `wavefront` format to the `query` command. This outputs the
  result of a raw or timeseries query in a format which can be fed
  back into Wavefront via a proxy.
* Use 1.6.0 of [wavefront-sdk](https://github.com/snltd/wavefront-sdk).
* Restructure the way different output formats are handled in a
  better, more flexible way.

## 2.7.0 (2018-07-04)
* Add a `-i` option to the `report` command, to send delta metrics.
* Fix delta metrics on the `write` command.

## 2.6.0 (2018-06-27)
* Anything which can be imported can be imported from STDIN. The CLI
  will do its best to work out if the format is YAML or JSON.

## 2.5.0 (2018-06-25)
* Support [derived
  metrics](https://docs.wavefront.com/derived_metrics.html).
* Remove options which were not actually supported.
* Smarter formatting of help pages.
* Pass API warnings through the the user on `query` commands.
* Add Unicode sparklines to `query` output.
* Better formatting of `query` output.
* Remove obsolete code and test files.

## 2.4.0 (2017-04-10)
* Support direct data ingestion via `report` command.
* Support writing delta metrics.
* Add `-q` to silenty write data points.
* Export alerts, alert targets and dashboards in HCL format, for
  easy integration with [Space Ape's
  Terraform
  provider](https://github.com/spaceapegames/terraform-provider-wavefront).

## 2.3.1 (2017-03-24)
* Fix broken handling of negative values in `write` command.

## 2.3.0 (2017-02-23)
* Add query aliases.

## 2.2.0 (2017-02-18)
* Add `alert firing` and `alert snoozed` subcommands.

## 2.1.6 (2017-01-11)
* Correctly handle `=` characters in `update` subcommands.

## 2.1.5 (2017-12-05)
* Allow the user to tag events when they are created.

## 2.1.4 (2017-11-15)
* `event create` bugfix.

## 2.1.3 (2017-10-31)
* Use credential mechanism from SDK instead of rolling our own.
* Fix bug which ignored supposedly supported environment variables,
  and add support for more.
* Cut dead wood out of codebase.
* Eradicate build warnings.

## 2.1.2 (2017-10-31)
* Fix no-op bug.
* Add BSD license.

## 2.1.1 (2017-10-12)
* Fix bug in relative time specifications.

## 2.1.0 (2017-10-12)
* Allow users to specify relative times, like `-10m`.

## 2.0.0 (2017-10-09)
* Support viewing and managing of integrations.
* Support notificants. (AKA alert targets).
* Support new source descriptions.
* Breaking change in `source` command.

## 1.0.3 (2017-08-25)
* Fix nil tag bug in terse source listing.

## 1.0.2 (2017-08-04)
* Greatly improve support for maintenance windows. They can now be
  extended, shrunk, and closed and created on the fly.

## 1.0.1 (2017-07-31)
* Report `no data` if a query returns no data.

## 1.0.0 (2017-07-28)
* First official release.
