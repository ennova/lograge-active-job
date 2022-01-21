# frozen_string_literal: true

module LogrageActiveJob
  module LogSubscribers
    class ActiveJobUniqueness < Base
      def lock(event)
        resource = event.payload[:resource]

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :locked
            data[:lock_key] = resource
          }
      end

      def runtime_lock(event)
        resource = event.payload[:resource]

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :runtime_locked
            data[:lock_key] = resource
          }
      end

      def unlock(event)
        resource = event.payload[:resource]

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :unlocked
            data[:lock_key] = resource
          }
      end

      def runtime_unlock(event)
        resource = event.payload[:resource]

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :runtime_unlocked
            data[:lock_key] = resource
          }
      end

      def conflict(event)
        resource = event.payload[:resource]

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :conflicted
            data[:lock_key] = resource
          }
      end

      def runtime_conflict(event)
        resource = event.payload[:resource]

        processing_data event,
          initial_data(event).tap { |data|
            data[:status] = :runtime_conflicted
            data[:lock_key] = resource
          }
      end
    end
  end
end
