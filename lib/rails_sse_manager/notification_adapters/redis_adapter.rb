# frozen_string_literal: true

module RailsSseManager
  class NotificationAdapter
    class RedisAdapter < NotificationAdapter
      def subscribe
        raise NotImplementedError
      end

      def process_event
        raise NotImplementedError
      end

      def publish
        raise NotImplementedError
      end
    end
  end
end
