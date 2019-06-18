# Changelog

## 4.0.0 (18/06/2019)
* `update` subcommand has been changed to `set`. (Breaking change.)
* `import` subcommand now accepts `--update` (`-u`) option, which
  lets you overwrite an existing object with a JSON or YAML
  description.
* Fix `tag searchpath` bug.

## 3.3.0 (10/06/2019)
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

## 3.2.3 (24/05/2019)
* Don't print erroneous pagination message when using `list --all`.
* Require 3.3.2 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 3.2.2 (16/05/2019)
* Smarter error messages.
* Require 3.3.1 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 3.2.1 (09/05/2019)
* Fix for new API ACL format.
* Require 3.3.0 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 3.2.0 (30/04/2019)
* New `apitoken` command lets you manage your own API tokens.
* Support for alert ACLs.
* Require 3.2.0 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 3.1.4 (02/05/2019)
* Fix `alert import` missing tags bug.
* Allow importing of notificants.

## 3.1.3 (24/04/2019)
* Fix `write distribution` bug. Points would be sent, but results
  could not be displayed, causing a crash unless you used `-q`.

## 3.1.2 (06/04/2019)
* Bugfix on handling of invalid config files.
* Explicitly specifying a missing config file now causes an error
  whether or not credentials available from other mechanisms.
* Require 3.0.2 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 3.1.1 (05/04/2019)
* Usernames do not have to be e-mail addresses.
* Require 3.0.1 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 3.1.0 (02/04/2019)
* Add `message read` command.

## 3.0.1 (23/03/2019)
* Fix `config about` bug.

## 3.0.0 (23/03/2019)
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

## 2.18.0 (22/02/2019)
* Add `usergroup` command, and extend `user` command to cover new
  RBAC features.
* Require 2.5.0 of [the SDK](https://github.com/snltd/wavefront-sdk).

## 2.17.0 (19/02/2019)
* Add `-O field,field` to all `list` commands. This lets you select
  the fields displayed in the output.

## 2.16.2 (29/12/2018)
* Fix typo in `query` help. CSV headers are produced with `-F
  headers`, not `-F header`.

## 2.16.1 (29/12/2018)
* Fix regression which broke query time ranges.
* Fix regression which made `--noop` silent unless `--verbose` was
  also specified.
* Fix crash if `wf metric` matched no series.
* Fix bug calculating query granularity when only one end of a
  time range is specified.
* Add much more comprehensive `--noop` tests.
* Better handling of `--noop` on commands which cannot support it.

## 2.16.0 (23/12/2018)
* Add `config` command to quickly set up and manage profiles.

## 2.15.2 (21/12/2018)
* Fix bug which caused an unhandled exception if CSV or Wavefront
  query outputs tried to process an empty data set.

## 2.15.1 (20/12/2018)
* Fix bug where `alert snoozed` and `alert firing` did the same
  thing.

## 2.15.0 (18/12/2018)
* Gracefully handle ctrl-c.
* Add `install` and `uninstall` subcommands to `wf alert`.
* Add `enable` and `disable` subcommands to `wf cloudintegration`.
* Add `fav` and `unfav` commands to `wf dashboard`.
* Add `alert install`, `alert uninstall`, `installed`, and
  `manifest` commands to `wf integration`.
* Require 2.2.0 of [wavefront-sdk](https://github.com/snltd/wavefront-sdk).

## 2.14.0 (15/12/2018)
* Add `-n` to `dashboard`'s `list` and `queries` commands to omit
  system-owned dashboards.
* Let `queries` subcommand accept an optional ID.

## 2.13.0 (11/12/2018)
* Add CSV output for `query` command.
* Add multiple format outputs for all applicable `alert`
  subcommands.
* Add `queries` subcommand for `alert` and `dashboard` subcommands,
  to quickly see which queries (and therefore timeseries) are being
  used.

## 2.12.0 (26/11/2018)
* Support SDK's new `unix` writer, which lets you write points to a
  local Unix datagram socket. This requires `-u unix` and `-S
  filename`.

## 2.11.0 (24/10/2018)
* Add `proxy versions` subcommand. Lists proxies and their versions,
  newest to oldest.

## 2.10.1 (22/10/2018)
* Fix bug seen when listing events with `-s` AND `-L`.

## 2.10.0 (22/10/2018)
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

## 2.9.3 (03/09/2018)
* Fix a bug where indefinitely snoozed alerts broke `wf alert
  snoozed`.

## 2.9.2 (22/08/2018)
* Fix regression which broke the `wf` command when it ran without a
  tty.

## 2.9.1 (22/08/2018)
* Use 1.6.2 of [wavefront-sdk](https://github.com/snltd/wavefront-sdk).

## 2.9.0 (22/08/2018)
* Create external links with new `link create` sub-command.
* Fix bug which stopped you writing points without a `.wavefront`
  configuration file.
* Improved error reporting.
* Bugfix on external link searching.
* Modify external link filters.
* Use 1.6.1 of [wavefront-sdk](https://github.com/snltd/wavefront-sdk).

## 2.8.0 (08/08/2018)
* Add `wavefront` format to the `query` command. This outputs the
  result of a raw or timeseries query in a format which can be fed
  back into Wavefront via a proxy.
* Use 1.6.0 of [wavefront-sdk](https://github.com/snltd/wavefront-sdk).
* Restructure the way different output formats are handled in a
  better, more flexible way.

## 2.7.0 (04/07/2018)
* Add a `-i` option to the `report` command, to send delta metrics.
* Fix delta metrics on the `write` command.

## 2.6.0 (27/06/2018)
* Anything which can be imported can be imported from STDIN. The CLI
  will do its best to work out if the format is YAML or JSON.

## 2.5.0 (25/06/2018)
* Support [derived
  metrics](https://docs.wavefront.com/derived_metrics.html).
* Remove options which were not actually supported.
* Smarter formatting of help pages.
* Pass API warnings through the the user on `query` commands.
* Add Unicode sparklines to `query` output.
* Better formatting of `query` output.
* Remove obsolete code and test files.

## 2.4.0 (10/04/2017)
* Support direct data ingestion via `report` command.
* Support writing delta metrics.
* Add `-q` to silenty write data points.
* Export alerts, alert targets and dashboards in HCL format, for
  easy integration with [Space Ape's
  Terraform
  provider](https://github.com/spaceapegames/terraform-provider-wavefront).

## 2.3.1 (24/03/2017)
* Fix broken handling of negative values in `write` command.

## 2.3.0 (23/02/2017)
* Add query aliases.

## 2.2.0 (18/02/2017)
* Add `alert firing` and `alert snoozed` subcommands.

## 2.1.6 (11/01/2017)
* Correctly handle `=` characters in `update` subcommands.

## 2.1.5 (05/12/2017)
* Allow the user to tag events when they are created.

## 2.1.4 (15/11/2017)
* `event create` bugfix.

## 2.1.3 (31/10/2017)
* Use credential mechanism from SDK instead of rolling our own.
* Fix bug which ignored supposedly supported environment variables,
  and add support for more.
* Cut dead wood out of codebase.
* Eradicate build warnings.

## 2.1.2 (31/10/2017)
* Fix no-op bug.
* Add BSD license.

## 2.1.1 (12/10/2017)
* Fix bug in relative time specifications.

## 2.1.0 (12/10/2017)
* Allow users to specify relative times, like `-10m`.

## 2.0.0 (09/10/2017)
* Support viewing and managing of integrations.
* Support notificants. (AKA alert targets).
* Support new source descriptions.
* Breaking change in `source` command.

## 1.0.3 (25/08/2017)
* Fix nil tag bug in terse source listing.

## 1.0.2 (04/08/2017)
* Greatly improve support for maintenance windows. They can now be
  extended, shrunk, and closed and created on the fly.

## 1.0.1 (31/07/2017)
* Report `no data` if a query returns no data.

## 1.0.0 (28/07/2017)
* First official release.
