class Heliotrope::Queue
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
    end

    class Put
      include Beefcake::Message
      repeated :msg, :bytes, 1
    end

    class Offer
      include Beefcake::Message
      repeated :msg, :bytes, 1
      optional :timeout, :int32, 2, default: 0
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
