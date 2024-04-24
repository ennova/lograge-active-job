require "bundler/setup"
require "lograge/active_job"
require "lograge"
require "global_id"
require "timecop"

GlobalID.app = "ExampleApp"

require "simplecov"
SimpleCov.start

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after do
    Timecop.return
  end
end
