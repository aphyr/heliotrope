module Heliotrope
  class Queue
    module ClientMethods
      def queue(queue)
        Queue.new self, queue
      end
    end
  end
end
