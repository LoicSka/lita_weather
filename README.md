# Lita::Weather

Lita handler for weather forecasts, this gem uses the www.wunderground.com api so get a free api key before you start using it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lita_weather'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lita_weather

## Usage

config.handlers.weather.default_city = "san francisco"
config.handlers.weather.api_key = "your_key_here"

lita weather today
lita weather on monday
lita weather today in Berlin



## Development

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/loicSka/lita_weather.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

