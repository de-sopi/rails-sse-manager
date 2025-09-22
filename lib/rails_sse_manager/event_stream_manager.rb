# frozen_string_literal: true

module RailsSseManager
  class EventStreamManager
    private_class_method :new
    attr_reader :active_stream_ids, :stream_queue

    @instance_mutex = Mutex.new

    def self.instance
      @instance_mutex.synchronize do
        @instance ||= new
      end
    end

    def self.add_stream(stream)
      return unless stream.is_a?(Stream)

      instance.stream_queue << stream
      instance.start_thread unless instance.thread_alive?
    end

    def self.active_stream_ids
      instance.active_stream_ids
    end

    def start_thread
      @thread_alive = true
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do |conn|
          conn.raw_connection.async_exec('LISTEN stream_events') # listen to data sent in the stream_events channel

          streams = []

          loop do
            # 1) ensure streams are added and cleaned up
            streams = prepare_streams(streams)
            @active_stream_ids = streams.map(&:id).uniq
            if streams.empty?
              @thread_alive = false
              Thread.current.exit
            end
            @thread.exit if streams.empty?

            # 2. process pg noticifactions
            # returns the channel name if message received within timeout, else nil
            conn.raw_connection.wait_for_notify(30) do |_channel, _pid, payload|
              message = Event.from_json(JSON.parse(payload.to_s))

              io_for_each_stream(streams) do |stream|
                stream.write(message)
              end
              # 3. if no message came through, check if any streams have been disconnected
            end || io_for_each_stream(streams, &:check_if_alive)
          end
        end
      end
    end

    def thread_alive?
      @thread_alive || false
    end

    private

    def initialize
      @stream_queue = Queue.new
      @thread = nil
      @active_stream_ids = []
    end

    def prepare_streams(streams)
      if stream_queue.size.positive? # rubocop:disable Style/IfUnlessModifier
        streams << @stream_queue.pop until @stream_queue.empty?
      end

      streams.reject!(&:closed?)

      streams
    end

    def io_for_each_stream(streams)
      streams.each do |stream|
        yield(stream) if block_given?
      rescue IOError, SocketError, Errno::EPIPE, Errno::ECONNRESET
        stream.close
        next
      end
    end
  end
end
