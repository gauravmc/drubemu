class Memory < Array
  SIZE = 0x10000
  
  def initialize(data)
    if data.size > SIZE
      fail "Source larger than memory"
    end
    replace Array.new(SIZE - data.size, "\x00\x00")
    unshift *data
    map! {|v| Word.new(v)}
  end
    
  class Word < String    
    def to_bin
      unpack("B*").first
    end

    def to_i
      unpack("B*").first.to_i 2
    end
    
    def to_hex
      unpack("H*").first
    end
    
    def lower_four
      self.to_i & 0xF
    end
    
    def lower_six
      (self.to_i >> 4) & 0x3F
    end
    
    def upper_six
      (self.to_i >> 10) & 0x3F
    end
  end
end
