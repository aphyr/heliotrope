module Heliotrope
  class Queue
    module ConnectionMethods
      def initialize(*a)
        super *a
        @qselect = Mutex.new
        @qtransaction = Mutex.new
      end
        
      def qput!(o)
        synchronize do
          send! Request.new(
            type: Request::Type::PUT,
            put: Request::Put.new(msg: [o])
          )
          recv! Response
        end
      end

      # Selects a queue for this connection to operate with. Inside the block,
      # the queue will be selected. Use the yielded connection to perform qput,
      # qget, etc.
      def qselect(queue)
        # It's official. Stateful protocols suck.
        @qselect.synchronize do
          if queue != @queue
            # Tell the server what queue we're using.
            @queue = queue
            synchronize do
              send! Request.new(
                  type: Request::Type::SELECT,
                  select: Request::Select.new(queue: queue)
                )
              recv!(Response)
            end
          end

          yield self if block_given?
        end
      end

      def qtake!(num = nil)
        case num
        when nil
          r = Request::Take.new num: 1
        else
          r = Request::Take.new num: num
        end

        synchronize do
          send! Request.new(
            type: Request::Type::TAKE,
            put: r
          )
          msgs = recv!(Response).msgs.map(&:data)

          if num
            msgs
          else
            msgs.first
          end
        end
      end

      def qtransaction
        @qtransaction.synchronize do
          begin
            synchronize do
              send! Request.new(type: Request::Type::BEGIN)
              recv! Response
            end
            yield self
            synchronize do
              send! Request.new(type: Request::Type::COMMIT)
              recv! Response
            end
          rescue Exception
            synchronize do
              send! Request.new(type: Request::Type::ROLLBACK), Response
              recv! Response
            end
            raise
          end
        end
      end
    end
  end
end
