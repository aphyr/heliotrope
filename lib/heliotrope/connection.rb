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
      close
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
      @socket.close rescue IOError
      @socket = nil
      super
      true
    end

    def closed?
      @socket.nil? or @socket.closed?
    end

    def inspect
      "(#{(Thread.current.object_id * 2).to_s(16)}) #{@host}:#{@port} #{@socket.inspect}"
    end
    
    def recv(*a)
      with_retry { recv! *a }
    end

    # Receive a protobufs message of class klass from socket s.
    def recv!(klass, s = @socket)
      begin
        len = Util.decode_uint32 s
        buffer = s.read(len) or raise EOFError
      rescue EOFError
        close
        raise
      end

      resp = klass.decode(buffer)
      resp.validate!
      r = resp
      puts "#{self} <- #{r.inspect}"
      r
    end

    def send *a
      with_retry { send! *a }
    end

    # Send a protobufs message on socket s
    def send!(message, s = @socket)
      encoded = message.encode.to_s
      puts "#{self} -> #{message.inspect}"
      s << Util.encode_uint32(encoded.bytesize)
      s << encoded
      s.flush
    end

    def to_s
      inspect
    end

    # ensures that errors will be rescued from the given block--but only the
    # outermost with_retry matters. In short, it asserts that the given block
    # is causally linked; failures require restarting the block from the
    # beginning.
    def with_retry
      if @wrapped_by_retry
        return yield
      end

      @wrapped_by_retry = true

      tries = 0

      begin
        tries += 1
        connect! unless @socket
        yield self
      rescue EOFError => e
        puts "#{self} #{e.inspect}"
        close
        raise if tries > 3
        retry
      rescue Errno::EPIPE => e
        p e
        close
        raise if tries > 3
        retry
      rescue Errno::ECONNREFUSED => e
        p e
        close
        raise if tries > 3
        retry
      rescue Errno::ECONNRESET => e
        p e
        close
        raise if tries > 3
        retry
      rescue Exception => e
        p e
        close
        raise
      ensure
        @wrapped_by_retry = false
      end
    end
  end
end
