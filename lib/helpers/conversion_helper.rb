require_relative '../memory'

module ConversionHelper
  def to_bindata(int)
    Memory::Word.new([int].pack("S>"))
  end
  
  def to_i(bin)
    bin.unpack("B*").first.to_i 2
  end
end