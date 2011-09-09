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
      @connections = []

      if opts[:host]
        add_connection host: opts[:host]
      end

      if opts[:hosts]
        opts[:hosts].each do |h|
          add_connection host: h
        end
      end

      if opts[:connections]
        opts[:connections].each do |c|
          add_connection c
        end
      end

      add_connection if connections.empty?
    end

    def add_connection(c = {})
      connection = Connection.new(c) unless c.kind_of? Connection
      @connections |= [connection]
    end

    # Return a connection for a request
    def connection
      @connections[rand @connections.size] or raise NoConnections
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
