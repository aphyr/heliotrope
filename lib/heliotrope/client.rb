module Heliotrope
  class Client
    class NoConnections < Heliotrope::Error; end

    attr_accessor :connections

    # host: 'foo'
    # port: 123
    # 
    # hosts: ['foo', 'bar', 'baz']
    #
    # connections: [
    #   {
    #     host: 'foo',
    #     port: 123
    #   },
    #   ...
    # ]
    def initialize(opts = {})
      @connections = {}
      @possibilities = []

      if opts[:host]
        @possibilities |= [Connection.new(host: opts[:host])]
      end

      if opts[:hosts]
        opts[:hosts].each do |h|
          @possibilities |= [Connection.new(host: h)]
        end
      end

      if opts[:connections]
        opts[:connections].each do |c|
          @possibilities |= [Connection.new(c)]
        end
      end

      if @possibilities.empty?
        @possibilities |= [Connection.new]
      end
    end

    # Return a connection for a request
    def connection
      @connections[Thread.current] or begin
        c = @possibilities[rand @possibilities.size]
        @connections[Thread.current] = c.dup
      end
    end

    # Remove connections owned by deceased threads
    def cleanup_connections
      @connections.keep_if do |thread, conns|
        thread.alive?
      end
    end

    def method_missing(method, *a, &block)
      connection.__send__(method, *a, &block)
    end

    def remove_connection(c)
      @connections.delete c
    end

    def with_connection
      connection.synchronize do
        yield
      end
    end
  end
end
