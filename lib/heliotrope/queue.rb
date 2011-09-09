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

    def initialize(client, queue)
      @client = client
      @queue = queue
    end

    def put(*a)
      @client.qselect @queue do |c|
        c.qput *a
      end
    end

    def take(*a)
      @client.qselect @queue do |c|
        c.qtake *a
      end
    end
  end
end
