# frozen_string_literal: true

module LogrageActiveJob
  module LogSubscribers
    class ActiveJob < Base
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
            data[:enqueued_at] = parse_time(job.enqueued_at)
          }
      end

      def perform(event)
        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = status(event.payload, default_status: :performed)
            data[:duration] = "#{event.duration.round(2)}ms"
          }
      end

      def enqueue_retry(event)
        payload = event.payload
        wait = event.payload[:wait]

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = payload[:error] ? :failed : :retrying
            data[:retry_in] = wait.to_i
          }
      end

      def retry_stopped(event)
        processing_data event, initial_data(event).tap { |data| data[:status] = :failed }
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
