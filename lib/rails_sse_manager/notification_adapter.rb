# frozen_string_literal: true

module RailsSseManager
  class NotificationAdapter
    def subscribe
      raise NotImplementedError
    end

    def process_event
      raise NotImplementedError
    end

    def publish
      raise NotImplementedError
    end

    def call
      RailsSseManager.config.notification_adapter.new
    end

    def channel_name
      @channel_name ||= RailsSseManager.config.channel_name
    end
  end
end
