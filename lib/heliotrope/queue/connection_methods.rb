module Heliotrope
  class Queue
    module ConnectionMethods
      def qput(o)
        t1 = Time.now
        send Request.new(
          type: Request::Type::PUT,
          put: Request::Put.new(msgs: [o])
        )
        r = recv Response
        puts (Time.now - t1)
        r
      end

      # Selects a queue for this connection to operate with. Inside the block,
      # the queue will be selected. Use the yielded connection to perform qput,
      # qget, etc.
      def qselect(queue)
        if queue != @queue
          # Tell the server what queue we're using.
          send Request.new(
            type: Request::Type::SELECT,
            select: Request::Select.new(queue: queue)
          )
          recv Response
          @queue = queue
        end
          
        yield self if block_given?
      end

      def qtake(num = nil)
        case num
        when nil
          send Request.new(
            type: Request::Type::TAKE,
            take: Request::Take.new(num: 1)
          )
          recv(Response).msgs.map(&:data).first
        else
          send Request.new(
            type: Request::Type::TAKE,
            take: Request::Take.new(num: num)
          )
          recv(Response).msgs.map(&:data)
        end
      end

      def qtransaction
        begin
          send! Request.new(type: Request::Type::BEGIN)
          recv! Response
          yield self
          send! Request.new(type: Request::Type::COMMIT)
          recv! Response
        rescue Exception
          send! Request.new(type: Request::Type::ROLLBACK)
          recv! Response
          raise
        end
      end
    end
  end
end
