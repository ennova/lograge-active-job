# LogrageActiveJob

Lograging ActiveJob logs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lograge'
gem 'lograge_active_job'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lograge_active_job

## Custom setup
### Output file path
You can configure output file path for lograge_active_job. (default is the path set in lograge)

```ruby
# config/initializers/lograge.rb
Rails.application.configure do
  config.lograge.active_job.logger = ActiveSupport::Logger.new(Rails.root.join("log/active_job.log"))
end
```

### Additional fields
You can configure additional fields, which will be logged for every exception.

```ruby
# config/initializers/lograge.rb
Rails.application.configure do
  config.lograge.active_job.custom_options = lambda do |event|
    {
      event_time: event.time.iso8601,
      status: event.payload[:exception_object].blank? ? 200 : 500
    }
  end
end
```
## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
