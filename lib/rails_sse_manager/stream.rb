# frozen_string_literal: true

module RailsSseManager
  class Stream
    attr_accessor :io, :id

    def initialize(io, id)
      @io = io
      @id = id
    end

    def write(event)
      return if closed?
      return if event.connection_id.present? && event.connection_id != id

      io.write("event: #{event.event}\ndata: #{JSON.generate(event.data)}\n\n")
    end

    def move_to_stream_thread
      EventStreamManager.add_stream(self)
    end

    def check_if_alive
      io.write("event: heartbeat\ndata:alive\n\n")
    end

    def close
      @io.close
    end

    def closed?
      @io.closed?
    end
  end
end
