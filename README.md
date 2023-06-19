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
#### A1 Verify connections logging in from specific networks
Understanding when and where connections are being attempted to your Snowflake instance from blocked IP address ranges is an important first line defence in keeping you safe.

* blocked IP address login events
* blocked IP address login aggregate
* login failures by ip address

#### A2 Monitor changes to Network Policies
Understanding if someone or something has changed your Network Policies is vital.
Most of the time these changes will be intended, but what if they are not?
* changes to network policies

#### A3 Monitor Network Policies exist
This is a light-weight version 
* Network policies exist

### Admin
* Scim token expiry
* Orphaned roles

### Performance
* Long Running Queries

