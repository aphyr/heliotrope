module Heliotrope
  class Queue
    require 'heliotrope/queue/msg'
    require 'heliotrope/queue/request'
    require 'heliotrope/queue/response'
    require 'heliotrope/queue/connection_methods'
    require 'heliotrope/queue/client_methods'

    class Heliotrope::Connection
      include ConnectionMethods
    end

    class Heliotrope::Client
      include ClientMethods
    end

    def self.dump(data)
      if data.kind_of? Array
        data.map do |e|
          e.to_s
        end
      else
        data.to_s
      end
    end

    def initialize(client, queue)
      @client = client
      @queue = queue
    end

    def clear *a
      @client.qselect @queue do |c|
        c.qclear *a
      end
    end
    
    def offer(*a)
      @client.qselect @queue do |c|
        c.qoffer *a
      end
    end

    def poll(*a)
      @client.qselect @queue do |c|
        c.qpoll *a
      end
    end

    def put(*a)
      @client.qselect @queue do |c|
        c.qput *a
      end
    end
    alias << put

    def take(*a)
      @client.qselect @queue do |c|
        c.qtake *a
      end
    end

    def transaction
      # Transactions are fixed to a particular connection. Hence
      # we yield a client which is backed *only* by that connection.
      @client.qtransaction do |conn|
        yield Queue.new(conn, @queue)
      end
    end
  end
end
