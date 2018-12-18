# Changelog

## 2.15.0
* Gracefully handle ctrl-c.
* Add `install` and `uninstall` subcommands to `wf alert`.
* Add `enable` and `disable` subcommands to `wf cloudintegration`.
* Add `fav` and `unfav` commands to `wf dashboard`.
* Add `alert install`, `alert uninstall`, `installed`, and
* `manifest` commands to `wf integration`.
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
