module Heliotrope
  class Queue
    module ConnectionMethods
      def close *a
        @queue = nil
      end

      def qclear(chunk_size = 100)
        loop do
          qpoll or return self
        end
      end

      def qoffer(data, timeout = 0)
        with_retry do
          send! Request.new(
            type: Request::Type::OFFER,
            offer: Request::Offer.new(datas: data, timeout: timeout)
          )
          recv! Response
          data
        end
      end
      
      def qpoll(timeout = nil)
        with_retry do
          send! Request.new(
            type: Request::Type::POLL,
            take: Request::Poll.new(num: 1, timeout: timeout)
          )
          if msgs = recv!(Response).msgs
            msgs.first.data
          end
        end
      end

      def qput(data)
        with_retry do
          send! Request.new(
            type: Request::Type::PUT,
            put: Request::Put.new(datas: data)
          )
          t1 = Time.now
          recv! Response
          puts Time.now - t1
          data
        end
      end

      # Selects a queue for this connection to operate with. Inside the block,
      # the queue will be selected. Use the yielded connection to perform qput,
      # qget, etc.
      def qselect(queue)
        with_retry do
          if queue != @queue
            # Tell the server what queue we're using.
            send! Request.new(
              type: Request::Type::SELECT,
              select: Request::Select.new(queue: queue)
            )
            recv! Response
            @queue = queue
          end
          
          yield self if block_given?
        end
      end
      
      def qtake
        with_retry do
          send! Request.new(
            type: Request::Type::TAKE,
            take: Request::Take.new(num: 1)
          )
          recv!(Response).msgs.map(&:data).first
        end
      end

      def qtransaction
        with_retry do
          begin
            send! Request.new(type: Request::Type::BEGIN)
            recv! Response
            yield self
            send! Request.new(type: Request::Type::COMMIT)
            recv! Response
          rescue Exception => e
            unless closed?
              send! Request.new(type: Request::Type::ROLLBACK)
              recv! Response
            end
            raise
          end
        end
      end
    end
  end
end
