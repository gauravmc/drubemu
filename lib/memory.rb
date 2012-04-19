class Memory < Array
  SIZE = 0x100
  
  class Word < String    
    def to_dec
      unpack("B*").first.to_i 2
    end

    def to_bin
      unpack("B*").first
    end
    
    def to_hex
      unpack("H*").first
    end
  end
  
  def initialize(data)
    if data.size > SIZE
      fail "Source larger than memory"
    end
    replace Array.new(SIZE - data.size, "\x00\x00")
    unshift *data
    map! {|v| Word.new(v)}
  end
end

