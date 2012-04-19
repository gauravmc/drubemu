require_relative 'memory'

class DCPU
  attr_reader :memory, :registers, :pc, :sp, :overflow
      
  def initialize(file)
    @pc, @sp, @overflow = 0, 0, 0
    @registers = Hash[%w{A B C X Y Z I J}.map(&:to_sym).zip(Array.new(8, 0).flatten)]
    load_into_memory file
  end
    
  def load_into_memory(file)
    data = []
    File.open(file, 'r') do |f|
      until f.eof?
        data << f.read(2)
      end
    end
    
    @memory = Memory.new data
  end
end