# frozen_string_literal: true

require "lograge/active_job/version"
require "lograge/active_job/railtie"
require "lograge/active_job/base_log_subscriber"
require "lograge/log_subscribers/active_job"

module Lograge
  module ActiveJob
    class << self
      attr_accessor :logger, :ignore_events

      def remove_existing_log_subscriptions
        ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
          next unless subscriber.is_a?(fetch_subscriber_class)

          Lograge.unsubscribe(:active_job, subscriber)
        end
      end

      def setup(app)
        Lograge::ActiveJob.remove_existing_log_subscriptions
        Lograge::LogSubscribers::ActiveJob.attach_to :active_job
        Lograge::ActiveJob.logger = app.config.lograge.active_job.logger
        Lograge::ActiveJob.ignore_events = app.config.lograge.active_job.ignore_events
      end

      def fetch_subscriber_class
        @fetch_subscriber_class ||=
          if rails_version_lt_6_1?
            ::ActiveJob::Logging::LogSubscriber
          else
            ::ActiveJob::LogSubscriber
          end
      end

      def rails_version_lt_6_1?
        defined?(::ActiveJob::Logging::LogSubscriber)
      end
    end
  end
end
