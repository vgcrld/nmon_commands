# NmonCommands


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nmon_commands'
```

And then execute:

    $ bundle install --path .

Or install it yourself as:

    $ gem install nmon_commands

## Usage

This is a small sinatra app used to get familiar with the Webix ui controls.

Start the app by 

``` 
bundle exec nmonview 
```

## API Endpoints

Get a list of all customers:
http://karl:10999/api/v1/customer

Get a customer details:
http://karl:10999/api/v1/customer/atsgroup/details

List the files for the UUID:
http://karl:10999/api/v1/customer/PSU/files/D8Aa74DA-CEE7-40dA-9B4B-C89ED25fb851

List the PS data for a specific filename:
http://karl:10999/api/v1/customer/atsgroup/psdata?filename=/share/prd01/process/atsgroup/archive/by_uuid/7713fA55-fB19-40aa-951a-ECd4bC8eFAd8/g01plinf03.20191011.130001.GMT__640815__.7713fA55-fB19-40aa-951a-ECd4bC8eFAd8.linux.gz

