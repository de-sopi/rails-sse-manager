# frozen_string_literal: true

module RailsSseManager
  class Config
    attr_accessor :notification_service, :channel_name

    # TODO: explain in Readme
    def initialize
      @notification_service = :postgres
      @channel_name = 'stream_events'
    end

    def notification_adapter
      case @notification_service # TODO: mention in readme
      when :postgres
        RailsSseManager::NotificationAdapter::PostgresAdapter
      when :redis
        RailsSseManager::NotificationAdapter::RedisAdapter
      when :active_support
        RailsSseManager::NotificationAdapter::ActiveSupportAdapter
      else
        raise RailsSseManagerError('[RailsSseManager]invalid service config. Use :postgres, :redis or :active_support')
      end
    end
  end
end
