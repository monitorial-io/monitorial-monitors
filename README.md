# Monitorial Monitors

This repository is an open source project that aims to provide a scripts which can be consumed within `dbt` and pushed out to `Snowflake` for use within `Snowflake Alerts` or `Snowflake Tasks` and the results then pushed through to the `Monitorial.io Notification Service` to provide a notification to the user.

## Installation Instructions
Add the following to your packages.yml file
```
  - git: https://github.com/monitorial-io/monitorial-monitors.git
    revision: "0.0.1-beta"
```

## Usage
the project namespace for this package is `dbt_monitorialio_monitors` and can be used as follows:

```
{{ dbt_monitorialio_monitors.monitor_name() }}
```

## Contributing

## Getting Started

