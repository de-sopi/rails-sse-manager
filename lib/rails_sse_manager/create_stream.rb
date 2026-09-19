# frozen_string_literal: true

module RailsSseManager
  module CreateStream
    def create_stream(stream_id)
      raise RailsSseManagerError('Rack Hijacking not supported') unless request.env['rack.hijack']

      request.env['rack.hijack'].call
      io = request.env['rack.hijack_io']

      send_headers(io)
      stream = RailsSseManager::Stream.new(io, stream_id)
      # write the handshake event directly — don't round-trip through NOTIFY/LISTEN
      io.write("event: connect\ndata: #{JSON.generate('connection confirmed')}\n\n")
      stream.move_to_stream_thread
    end

    private

    def send_headers(io)
      headers = [
        'HTTP/1.1 200 OK',
        'Content-Type: text/event-stream',
        'Connection: keep-alive'
      ]
      io.write(headers.map { |header| "#{header}\r\n" }.join)
      io.write("\r\n")
      io.flush
    rescue StandardError => e
      Rails.logger.error e
      stream.close
      raise e
    end
  end
end
