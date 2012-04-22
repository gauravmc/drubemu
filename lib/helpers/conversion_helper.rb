require_relative '../memory'

module ConversionHelper
  def to_bindata(int)
    if int.is_a? Integer
      Memory::Word.new([int].pack("S>"))
    else
      int
    end
  end
  
  def to_i(bin)
    bin.unpack("B*").first.to_i 2
  end
  
  def to_hex(int)
    int.to_s(16)
  end
end