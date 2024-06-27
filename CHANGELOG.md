#Monitorial.io Monitors Change Log

## 1.0.6
* added new monitor for `trust_center` findings to monitor the trust center for any changes

## 1.0.5
* added new monitor `omnata_sync_failed` to monitor failed syncs
* added new monitor `omnata_sync_incomplete` to monitor incomplete syncs

## 1.0.4
* added new monitor `login_failures_by_username_detailed` which shows the username, ip addresses used, authentication method and exception thrown
* updated monitor `blocked_ip_address_events` to refer to current_timestamp instead of current_time when doing a time_filter
* updated monitor `login_failures_by_ip_address` to refer to current_timestamp instead of current_time when doing a time_filter

## 1.0.3
* added version information to yml definitions for Monitorial.io purposes
* updated Monitorial.io documentation generation python scripts
* added new monitors for snowpipes `pipe_channel_error`, `pipe_outstanding_messages`, `pipe_freshness`,`pipe_status`
* added new monitors for streams `streams_invalid_table`, `streams_invalid`, `streams_stale_after`, `streams_stale`
* added new monitors for tables/views `is_not_null`, `source_freshness`

## 1.0.2
* monitor modified: High Priviliage Grants - added more information to be returned and updated the query to be more efficient

## 1.0.1
* new monitor added: RBAR Detection Monitor
