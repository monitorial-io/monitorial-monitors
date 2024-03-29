# Monitorial Monitors

This repository is an open source project that aims to provide scripts which can be consumed within `dbt` and pushed out to `Snowflake`.  It is also possible to remove the `Jinja` tags and use as straight SQL code.
 
These scripts can be used and scheduled with `Snowflake Alerts` or `Snowflake Tasks`.

The easy and quickest way to consume and deploy these Snowflake monitors is with the Snowflake monitoring service monitorial.io (https://manager.monitorial.io) which has a Wizard where you can select the
Snowflake monitors you want and monitorial.io will deploy these for you and send alerts to the destinations of your choice such as Slack, Teams, Webhook, Splunk, Azure Log Analytics, AWS Cloudwatch, Email


## Installation Instructions
Add the following to your packages.yml file
```
  - git: https://github.com/monitorial-io/monitorial-monitors.git
    revision: "1.0.0"
```

## Usage
the project namespace for this package is `dbt_monitorialio_monitors` and can be used as follows:

```
{{ dbt_monitorialio_monitors.monitor_name() }}
```
for example
```
{{ dbt_monitorialio_monitors.failed_logins(time_filter=1400) }}
```

## Contributing
to contribute to this project please fork the repository and submit a pull request.

Please ensure the yml documentation has been updated to include:
```yml
macros:
  - name: <<name of your macro which matches your filename>>
    description: <<description of your macro>>
    docs:
      show: true
    monitorial:
      version: 1.0.3
      defaults:
        schedule: <<CRON schedule this should be run on>>
        severity: "<<severity level to be associated when a result is returned>>"
        message: "<<message to be sent out in the notification>>"
        message_type: "<<type of message this represents (eg security)>>"
        environment: "<<environment in which the monitor is to be deployed in>>"
      column_filters:
        datatypes: []
    arguments:
      - name: <<name of your argument>>
        type: <<data type>>
        description: <<description of your argument>>
      - name: ...
        type: ...
        description: ...
```


## Available Macros
### Performance

| name                 | description                                                                                                                                                                                                 |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| long_running_queries | Returns a list of queries that have been running for more than the specified timeframe                                                                                                                      |
| rbar_detection       | Detect row-by-row processing queries repeatedly executed within the same session as these are a high priority for tuning. Ref:  https://www.analytics.today/blog/top-3-snowflake-performance-tuning-tactics |

### Security Administration
| name                                | description                                                                  |
| ----------------------------------- | ---------------------------------------------------------------------------- |
| orphaned_roles                      | Returns a list of orphaned roles                                             |
| scim_token_expiry                   | Alerts a configurable numbers of days has past since the last token creation |
| login_failures_by_username_detailed | Count of login failures by username                                          |

### Snowflake Security Practices

| name                               | description                                                                                                                                                                                                                                                                                                                               |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| blocked_ip_address_events          | Blocked ip address login failures (this requires Network Policies to be configured)                                                                                                                                                                                                                                                       |
| login_failures_by_ip_address       | Count of login failures by ip address                                                                                                                                                                                                                                                                                                     |
| blocked_ip_address_aggregate       | Blocked ip address login failures aggregated by username, ip address, driver and authentication type (this requires Network Policies to be configured)                                                                                                                                                                                    |
| changes_to_network_policies        | Monitor changes to Network Policies and associated objects                                                                                                                                                                                                                                                                                |
| network_policy_exists              | Monitors for the presence of network policy                                                                                                                                                                                                                                                                                               |
| altered_client_sessions            | Monitor for client applications that are keeping sessions open longer than desired by policy                                                                                                                                                                                                                                              |
| public_role_grants                 | The public role should have the fewest possible grants (read none). Every user in a Snowflake account has the public role granted to them. Monitor QUERY_HISTORY for alterations or grants to the public role                                                                                                                             |
| unauthorized_privilege_grants      | Snowflake recommends using a designated role for all user management tasks. Monitor that all user and role grants originate from this role, and that this role is only granted to appropriate users                                                                                                                                       |
| admin_roles_query_check            | Monitor for all instances of a user using the default Snowflake admin roles to ensure their use is appropriate                                                                                                                                                                                                                            |
| user_creation                      | Monitors for the creation of users                                                                                                                                                                                                                                                                                                        |
| user_creation_non_admin            | Monitors for user creation by non admin roles                                                                                                                                                                                                                                                                                             |
| user_altered                       | Monitors occurrences of altered users                                                                                                                                                                                                                                                                                                     |
| user_altered_key_pair              | Monitors occurrences of altered users key pair auth removal                                                                                                                                                                                                                                                                               |
| user_altered_mfa_bypass            | Monitors occurrences of altered users mfa bypass time period                                                                                                                                                                                                                                                                              |
| enabled_user_previously_disabled   | Monitors instances where a previously disabled user has been enabled                                                                                                                                                                                                                                                                      |
| user_altered_to_plaintext_password | Monitor for the enablement of plaintext user passwords                                                                                                                                                                                                                                                                                    |
| scim_api_calls                     | "Applicable if SCIM user-provisioning via the REST API is configured. Monitor SCIM API calls to ensure API requests comply with policy https://docs.snowflake.com/en/user-guide/scim-intro#auditing-with-scim"                                                                                                                            |
| high_privilege_grants              | Monitors high privilege query activity that involves elevated privileges in your Snowflake Account                                                                                                                                                                                                                                        |
| accountadmin_role_grants           | The Snowflake role ACCOUNTADMIN should be closely monitored for granting to new users                                                                                                                                                                                                                                                     |
| authentication_method_by_user      | Monitors the number of times each user authenticated and the authentication method they used                                                                                                                                                                                                                                              |
| not_using_sso_auth                 | Monitor if users who have used SSO before are using other authentication methods instead After users successfully authenticate using SSO, they should not be using other methods                                                                                                                                                          |
| by_key_pair_auth                   | Monitor the use of key pair authentication by querying login attempt                                                                                                                                                                                                                                                                      |
| has_key_pair_and_password          | Monitor if exclusive Key Pair authentication users are configured to use other authentication methods.  Users who have key pair authentication should be using it exclusively                                                                                                                                                             |
| has_key_pair_using_other           | Monitor if exclusive Key Pair authentication users are configured to use other authentication methods.  Users who have key pair authentication should be using it exclusively                                                                                                                                                             |
| has_key_pair_using_password        | Monitor if users who have used key/pair authentication before are using password methods instead After users successfully authenticate using key/pair, they should not be using passwords                                                                                                                                                 |
| frequently_authenticated_users     | Identifying Users who login frequently can help spot anomalies or unexpected behavior                                                                                                                                                                                                                                                     |
| scim_token_creation                | SCIM access tokens have a six-month lifespan so it is important to track how many were generated This monitor needs accountadmin right to run, so careful planning required to implement this monitor                                                                                                                                     |
| failed_login_attempts_concurrent   | The following approach returns results based on either the FAILED_LOGINS count or the log in failure rate (AVERAGE_SECONDS_BETWEEN_LOGIN_ATTEMPTS). This approach helps distinguish a brute force attack from a human who is struggling to remember their password. There are inline comments on how to adjust the query to limit results |
| failed_login_attempts              | Failed login monitor grouped by user and first auth method                                                                                                                                                                                                                                                                                |
| mfa_auth_stats                     | Multi factor authentication stats                                                                                                                                                                                                                                                                                                         |
| password_login_with_mfa            | Most recent logins with password when MFA is enabled                                                                                                                                                                                                                                                                                      |
| periodic_rekey_enabled             | Checks that automatic data rekeying is turned on to provide additional data security                                                                                                                                                                                                                                                      |
| periodic_rekey_changes             | Changes to this setting are rare and deserving of scrutiny                                                                                                                                                                                                                                                                                |
| integration_object_changes         | Because integrations can enable a new means of access to Snowflake data, closely monitor for new integrations or the modification of existing integrations                                                                                                                                                                                |
| security_integration_changes       | Because security integrations can enable a new means of access to Snowflake data, closely monitor for new integrations or the modification of existing security integrations                                                                                                                                                              |


### Data Quality

| name                                      | description                                                                                                                                                                                                                            |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| pipe_channel_error                        | Checks to see if an error message has been produced when attempting to read messages from the associated Google Cloud Pub/Sub queue or Microsoft Azure Event Grid storage queue. If there is an error then a notification will be sent |
| pipe_freshness                            | Checks to see when the most recent file was loaded successfully by Snowpipe into the destination table. If the file is older than the freshness_threshold then a notification will be sent                                             |
| pipe_outstanding_messages                 | Checks the number of messages in the queue that have been queued but not received yet and number of files queued for loading by the pipe. If either of these values exceed the threshold then a notification will be sent              |
| pipe_status                               | Checks the current execution state of a pipe. Any status except those in the exception list will trigger an notification to be sent                                                                                                    |
| streams_gone_invalid                      | Checks to see if there are any streams cannot be queried successfully for the given databases. If any are found, a notification will be sent.                                                                                          |
| streams_with_invalid_tables               | Checks to see if there are any streams have invalid base tables for the given databases. If any are found, a notification will be sent.                                                                                                |
| streams_gone_stale                        | Checks to see if there are any streams have gone stale for the given databases. If any are found, a notification will be sent.                                                                                                         |
| streams_going_stale                       | Checks to see if there are any streams which may become stale if they aren't consumed from for the given databases. If any are found, a notification will be sent.                                                                     |
| not_null                                  | Checks to see the presence of a null value. If the results contains a null then a notification will be sent                                                                                                                            |
| source_freshness                          | Checks to see when data was retrieved last, if the time exeeds the specified expectation then a notification will be sent                                                                                                              |
| expect_column_values_to_be_between        | Checks to see if the column has a value between those specified, if any rows exceed the limits then a notification will be sent                                                                                                        |
| expect_column_value_lengths_to_be_between | Checks to see if column entries to be strings with length between a min_length value and a max_length value (inclusive). If any rows falls outside this range then a notification will be sent                                         |
| expect_column_value_lengths_to_equal      | Checks to see if column entries to be strings with a specific length. If any rows don't match outside this range then a notification will be sent                                                                                      |