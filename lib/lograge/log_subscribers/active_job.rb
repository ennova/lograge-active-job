# frozen_string_literal: true

module Lograge
  module LogSubscribers
    class ActiveJob < Lograge::ActiveJob::BaseLogSubscriber
      def enqueue(event)
        payload = event.payload
        job = payload[:job]

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = status(payload, default_status: :enqueued)
            data[:scheduled_at] = parse_time(job.scheduled_at)
            data.compact!
          }
      end
      alias_method :enqueue_at, :enqueue

      def perform_start(event)
        payload = event.payload
        job = payload[:job]

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :performing
            unless Lograge::ActiveJob.rails_version_lt_6_1?
              data[:enqueued_at] = parse_time(job.enqueued_at)
            end
          }
      end

      def perform(event)
        ex = event.payload[:exception_object]

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = status(event.payload, default_status: :performed)
            data[:duration] = event.duration.round(2)
            data[:error] = "#{ex.class}: #{ex.message}" if ex
          }
      end

      def enqueue_retry(event)
        payload = event.payload
        wait = event.payload[:wait]
        ex = event.payload[:error]

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :retrying
            data[:retry_in] = wait.to_i
            data[:error] = "#{ex.class}: #{ex.message}" if ex
          }
      end

      def retry_stopped(event)
        ex = event.payload[:error]

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :failed
            data[:error] = "#{ex.class}: #{ex.message}" if ex
          }
      end
      alias_method :discard, :retry_stopped

      private

      def status(payload, default_status:)
        if payload[:exception_object]
          :failed
        elsif payload[:aborted]
          :aborted
        else
          default_status
        end
      end
    end
  end
end
