# frozen_string_literal: true

module RailsSseManager
  class NotificationAdapter
    class PostgresAdapter < NotificationAdapter
      def subscribe
        ActiveRecord::Base.connection_pool.with_connection do |event_subscription|
          event_subscription.raw_connection.async_exec("LISTEN #{channel_name}")

          yield event_subscription
        end
      end

      def process_event(event_subscription)
        event_subscription.raw_connection.wait_for_notify(30) do |_channel, _pid, payload|
          yield payload
        end
      end

      def publish
        raise NotImplementedError
      end
    end
  end
end
