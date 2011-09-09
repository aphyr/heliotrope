class Heliotrope::Queue
  class Response
    include Beefcake::Message

    module Retval
      REQ_OK = 0
      REQ_ERROR = 1
    end

    module Type
      MSG_RESPONSE = 1
      CMD_RESPONSE = 2
      TOPIC_MESSAGE = 3
    end

    required :retval, Retval, 1, default: Retval::REQ_OK
    required :type, Type, 2, default: Type::CMD_RESPONSE
    optional :status, :string, 3
    repeated :msgs, Msg, 4
    optional :topic, :string, 5

    def validate!
      if retval != Retval::REQ_OK
        raise Error, status
      end
    end
  end
end
