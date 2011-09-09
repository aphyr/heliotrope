module Heliotrope
  class Queue
    class Request
      include Beefcake::Message

      module Type
        SELECT = 1
        PUT = 2
        OFFER = 3
        TAKE = 4
        POLL = 5

        const_set 'BEGIN', 6
        COMMIT = 7
        ROLLBACK = 8
      end

      class Select
        include Beefcake::Message
        required :queue, :string, 1

        def queue=(q)
          @queue = q.to_s
        end
      end

      class Put
        include Beefcake::Message
        repeated :datas, :bytes, 1
        
        def datas=(data)
          @datas = Queue.dump([*data])
        end
      end

      class Offer
        include Beefcake::Message
        repeated :datas, :bytes, 1
        optional :timeout, :int32, 2, default: 0
        
        def datas=(data)
          @datas = Queue.dump([*data])
        end
      end

      class Take
        include Beefcake::Message
        required :num, :int32, 1, default: 1
      end

      class Poll
        include Beefcake::Message
        required :num, :int32, 1, default: 1
        optional :timeout, :int32, 2, default: 0
      end

      required :type, Type, 1
      optional :select, Select, 2
      optional :put, Put, 3
      optional :offer, Offer, 4
      optional :take, Take, 5
      optional :poll, Poll, 6
    end
  end
end
