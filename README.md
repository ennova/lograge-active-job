# Lograge::ActiveJob

You get a single line with all the important information, like this:
```log
 "job_class=UserJob job_id=2692c069-8e57-453a-9bbd-6bbe094163ca adapter=Async queue_name=default args=args, gid://ExampleApp/UserModel/user-id-42 status=performed duration=1000.0ms"
```

## Installation

In your Gemfile:

```ruby
gem 'lograge'
gem 'lograge-active-job'
```

Enable it in an initializer or the relevant environment config:
```ruby
# config/initializers/lograge.rb
# OR
# config/environments/production.rb
Rails.application.configure do
  config.lograge.active_job.enabled = true
end
```
To further clean up your logging, you can also tell Lograge to skip log messages meeting given criteria. You can skip log messages generated from ActionMailer events:
```ruby
Rails.application.configure do
  config.lograge.active_job.ignore_events = ["perform_start"]
end
```
## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
