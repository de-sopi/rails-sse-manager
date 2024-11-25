# frozen_string_literal: true

require 'rails_sse_manager/create_stream'
require 'rails_sse_manager/event_stream_manager'
require 'rails_sse_manager/event'
require 'rails_sse_manager/stream'
require 'rails_sse_manager/version'

module RailsSseManager
  class RailsSseManagerError < StandardError; end
end
