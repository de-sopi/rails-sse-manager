# frozen_string_literal: true

module RailsSseManager
  class NotificationAdapter
    def self.call
      RailsSseManager::Config.new.notification_adapter.new
    end

    def subscribe
      raise NotImplementedError
    end

    def process_event
      raise NotImplementedError
    end

    def publish
      raise NotImplementedError
    end

    def channel_name
      @channel_name ||= RailsSseManager::Config.new.channel_name
    end
  end
end
