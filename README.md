# Monitorial Monitors

This repository is an open source project that aims to provide scripts which can be consumed within `dbt` and pushed out to `Snowflake`.  It is also possible to remove the `Jinja` tags and use as straight SQL code.
 
These scripts can be used and scheduled with `Snowflake Alerts` or `Snowflake Tasks`.

The easy and quickest way to consume and deploy these Snowflake monitors it with the Snowflake monitoring service monitorial.io (https://manager.monitorial.io) which has a Wizard where you can select the Snowflake monitors you want and monitorial.io will deploy these for you and send alerts to the destinations of your choice (Slack, Teams, Webhook, Splunk, Azure Log Analytics, AWS Cloudwatch or Email)


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

## Available Macros

### Snowflake Security Features Checklist
## A1 Verify connections logging in from specific networks


### Admin
* Scim token expiry
* Orphaned roles

### Performance
* Long Running Queries

