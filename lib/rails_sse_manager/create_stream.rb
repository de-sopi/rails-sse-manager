# frozen_string_literal: true

module RailsSseManager
  module CreateStream
    def create(stream_id)
      raise RailsSseManagerError unless env['rack.hijack']

      request.env['rack.hijack'].call
      io = request.env['rack.hijack_io']

      send_headers(io)
      stream = Stream.new(io, stream_id)
      stream.move_to_stream_thread
    end

    private

    def send_headers(stream)
      headers = [
        'HTTP/1.1 200 OK',
        'Content-Type: text/event-stream',
        'Connection: keep-alive'
      ]
      stream.write(headers.map { |header| "#{header}\r\n" }.join)
      stream.write("\r\n")
      stream.flush
    rescue StandardError => e
      Rails.logger.error e
      stream.close
      raise e
    end
  end
end
