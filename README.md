# Reliquary [![Gem Version](https://badge.fury.io/rb/reliquary.svg)](https://badge.fury.io/rb/reliquary)

Reliquary is a client for the [New Relic REST API v2](https://docs.newrelic.com/docs/apis/rest-api-v2).  It provides an alternative to the deprecated [newrelic_api](https://github.com/newrelic/newrelic_api) gem.

## TL;DR

```shell
$ export NEWRELIC_API_KEY='<your API key>'
```

```ruby
apps = Reliquary::API::Applications.new

my_app = apps.list(name: 'My App')

my_app[0][:id]
#=> 123467

apps.list(lang: :java).collect {|app| app[:name]}.sort
#=> <sorted list of your Java apps' names>
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reliquary'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install reliquary

## Usage

The New Relic REST API v2 has the following sections (after each section is the minimum version of Reliquary implementing that section):

* Alerts Channels
* Alerts Events
* Alerts External Service Conditions
* Alerts Incidents
* Alerts Plugins Conditions
* Alerts Policies
* Alerts Policy Channels
* Alerts Synthetics Conditions
* Alerts Violations
* Application Hosts
* Application Instances
* Applications (0.1.0)
* Browser Applications
* Components
* Key Transactions (0.1.0)
* Labels
* Legacy Alert Policies
* Mobile Applications
* Notification Channels
* Plugins
* Servers
* Usages
* Users

For some reason the [API Explorer](https://rpm.newrelic.com/api/explore) does not sort these categories lexically.  I'll update this document as I implement additional sections of the API.

Each section of the API is implemented as a class under the `Reliquary::API` namespace.  Each of these classes exposes methods corresponding to the API methods described by the API Explorer.  When methods take parameters (required or optional), pass them in as a typical params hash.

Access to the API requires an [API key](https://docs.newrelic.com/docs/apis/rest-api-v2/requirements/api-keys).  Reliquary reads your API key at runtime from the `NEWRELIC_API_KEY` environment variable.  If you really want to provide your API key via some other method, or change the API key while the program is running, then you'll need to create your own instance of `Reliquary::Client` with a different API key and then pass it in when initializing instances of the API section classes.

## Development

* write tests
* handle HTTP error codes
* implement additional API sections
* fix YARDoc errors

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hakamadare/reliquary. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

