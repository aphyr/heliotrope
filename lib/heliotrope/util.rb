module Heliotrope::Util
  def self.encode_uint32(n)
    s = ''

    if n < 0 or n > ((1<<31) - 1)
      raise ArgumentError, 'out of bounds'
    end

    while true
      bits = n & 0x7F
      n >>= 7
      if n == 0
        return s << bits
      end
      s << (bits | 0x80)
    end
  end

  def self.decode_uint32(stream)
    n = shift = 0
    while true
      if shift >= 64
        raise Beefcake::BufferOverflowError, "varint"
      end
      b = stream.read(1) or raise EOFError

      ## 1.8.6 to 1.9 Compat
      if b.respond_to?(:ord)
        b = b.ord
      end

      n |= ((b & 0x7F) << shift)
      shift += 7
      if (b & 0x80) == 0
        return n
      end
    end
  end
end
