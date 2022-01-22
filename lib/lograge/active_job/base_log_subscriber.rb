# frozen_string_literal: true

require "active_support/log_subscriber"

module Lograge
  module ActiveJob
    class BaseLogSubscriber < ActiveSupport::LogSubscriber
      protected

      def processing_data(event, data)
        return if event_ignore?(event.name)

        logger.send(Lograge.log_level, Lograge.formatter.call(data))
      end

      def initial_data(event)
        payload = event.payload
        job = payload[:job]

        {
          job_class: job.class.name,
          job_id: job.job_id,
          adapter: adapter_name(payload[:adapter]),
          queue_name: job.queue_name,
          args: args_info(job.arguments)
        }
      end

      private

      def adapter_name(adapter)
        adapter.class.name.demodulize.remove("Adapter")
      end

      def args_info(args)
        Array(args).any? ? args.flat_map { |arg| format(arg) }.join(", ") : ""
      end

      def format(arg)
        case arg
        when Hash
          arg.transform_values { |value| format(value) }
        when Array
          arg.map { |value| format(value) }
        when GlobalID::Identification
          arg.to_global_id
        else
          arg
        end
      rescue
        arg
      end

      def event_ignore?(name)
        !!Array(Lograge::ActiveJob.ignore_events).index(name.split(".").first)
      end

      def logger
        Lograge::ActiveJob.logger.presence || Lograge.logger.presence || super
      end

      def custom_options(event)
        Lograge::ActiveJob.custom_options(event) || {}
      end

      def parse_time(time)
        Time.parse(time).utc if time
      end
    end
  end
end
