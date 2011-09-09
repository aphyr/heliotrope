class Heliotrope::Queue::Msg
  include Beefcake::Message

  required :data, :bytes, 1
end
