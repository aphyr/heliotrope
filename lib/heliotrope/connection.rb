module Heliotrope
  class Connection
    class ServerError < Heliotrope::Error; end
    class Retryable < Heliotrope::Error; end
    class RetryableServerError < Heliotrope::Retryable; end
    class InvalidResponse < Heliotrope::Retryable; end

    require 'thread'
    require 'socket'

    HOST = '127.0.0.1'
    PORT = 7123

    attr_accessor :host, :port, :socket

    # A particular socket connection. NOT threadsafe.
    def initialize(opts = {})
      super

      @host = opts[:host] || HOST
      @port = opts[:port] || PORT
    end

    def initialize_copy(other)
      super other

      @socket = nil
    end

    def ==(other)
      other.kind_of? Connection and 
      other.host == @host and 
      other.port == @port
    end

    def connect!
      @socket = TCPSocket.new @host, @port
      @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      @socket
    end

    def close
      @socket.close
    end

    def closed?
      @socket.closed?
    end

    def recv(*a)
      with_retry { recv! *a }
    end

    # Receive a protobufs message of class klass from socket s.
    def recv!(klass, s = @socket)
      len = Util.decode_uint32 s
      buffer = s.read(len) or raise EOFError
      resp = klass.decode(buffer)
      resp.validate!
      resp
    end

    def send *a
      with_retry { send! *a }
    end

    # Send a protobufs message on socket s
    def send!(message, s = @socket)
      encoded = message.encode.to_s
      s << Util.encode_uint32(encoded.bytesize)
      s << encoded
      s.flush
    end

    def with_retry
      tries = 0

      begin
        tries += 1
        connect! unless @socket
        yield self
      rescue Errno::EPIPE => e
        raise if tries > 3
        @socket = nil
        retry
      rescue Errno::ECONNREFUSED => e
        raise if tries > 3
        @socket = nil
        retry
      rescue Errno::ECONNRESET => e
        raise if tries > 3
        @socket = nil
        retry
      end
    end
  end
end
