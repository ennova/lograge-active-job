# frozen_string_literal: true

require "active_support/log_subscriber"

module LogrageActiveJob
  module LogSubscribers
    class Base < ActiveSupport::LogSubscriber
      protected

      def processing_data(event, data)
        return if event_ignore?(event.name)

        data.merge!(custom_options(event))
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
        Array(args).any? ? args.map { |arg| format(arg).inspect }.join(", ") : []
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
        !!LogrageActiveJob.ignore_events.index(name.split(".").first)
      end

      def logger
        LogrageActiveJob.logger.presence || Lograge.logger.presence || super
      end

      def custom_options(event)
        LogrageActiveJob.custom_options(event) || {}
      end

      def parse_time(time)
        Time.parse(time).utc if time
      end
    end
  end
end
