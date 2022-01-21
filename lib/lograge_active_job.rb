# frozen_string_literal: true

require "lograge_active_job/version"
require "lograge_active_job/log_subscribers/base"
require "lograge_active_job/log_subscribers/active_job"
require "lograge_active_job/log_subscribers/active_job_uniqueness"
require "lograge_active_job/railtie"

module LogrageActiveJob
  module_function

  mattr_accessor :logger, :ignore_events

  # Custom options that will be appended to log line
  #
  # Currently supported formats are:
  #  - Hash
  #  - Any object that responds to call and returns a hash
  #
  mattr_writer :custom_options

  def custom_options(event)
    if @@custom_options.respond_to?(:call)
      @@custom_options.call(event)
    else
      @@custom_options
    end
  end

  def remove_existing_log_subscriptions
    ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
      next unless subscriber.is_a?(ActiveJob::LogSubscriber)

      unsubscribe(:active_job, subscriber)
      if defined?(ActiveJob::Uniqueness) && subscriber.patterns.keys.first.end_with?("_uniqueness")
        unsubscribe(:active_job_uniqueness, subscriber)
      end
    end
  end

  def unsubscribe(component, subscriber)
    events = subscriber.public_methods(false).reject { |method| method.to_s == "call" }
    events.each do |event|
      ActiveSupport::Notifications.notifier
        .listeners_for("#{event}.#{component}").each do |listener|
          next unless listener.instance_variable_get("@delegate") == subscriber

          ActiveSupport::Notifications.unsubscribe listener
        end
    end
  end

  def setup(app)
    LogrageActiveJob.remove_existing_log_subscriptions
    LogrageActiveJob::LogSubscribers::ActiveJob.attach_to :active_job
    if activejob_uniqueness_defined?
      LogrageActiveJob::LogSubscribers::ActiveJobUniqueness.attach_to :active_job_uniqueness
    end
    LogrageActiveJob.logger = app.config.lograge.active_job.logger
    LogrageActiveJob.custom_options = app.config.lograge.active_job.custom_options
    LogrageActiveJob.ignore_events = app.config.lograge.active_job.ignore_events
  end

  def activejob_uniqueness_defined?
    defined?(ActiveJob::Uniqueness) &&
      defined?(LogrageActiveJob::LogSubscribers::ActiveJobUniqueness)
  end
end
