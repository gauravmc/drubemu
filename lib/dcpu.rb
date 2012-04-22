require_relative 'memory'
require_relative 'instruction'

class DCPU
  attr_accessor :program_size, :cycle, :overflow, :pc, :registers, :memory, :sp
  
  REGISTERS = %w{A B C X Y Z I J}.map!(&:to_sym)
      
  include ConversionHelper
  
  def initialize(file)
    @pc, @overflow, @cycle, @ins_count, @sp = 0, 0, 0, 0, 0
    @registers = Hash[(0x00..0x07).to_a.zip(Array.new(8, Memory::Word.new("\x00\x00")).flatten)]
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
  
  def [](address)
    @memory[address]
  end

  def []=(address, value)
    @memory[address] = value
  end
    
  def push(value)
    @sp = 65536 if @sp == 0
    @sp -= 1
    self[@sp] = value
  end

  def pop
    value = peek
    @sp += 1
    value
  end

  def peek
    self[@sp]
  end
  
  def run
    loop do
      word = next_word
      break if @pc == @program_size and @pc = @program_size - 1
      process word
    end
  end
  
  def next_word
    word = self[@pc]
    @pc += 1
    word
  end
      
  def process(word)
    opcode = word.lower_four
    if opcode.zero?
      opcode = word.lower_six
      instruction = NonBasicInstruction.new(opcode, self)
      instruction.a.code = word.upper_six
    else
      instruction = BasicInstruction.new(opcode, self)
      instruction.a.code = word.lower_six
      instruction.b.code = word.upper_six
    end
    instruction.execute
  end
    
  def process_value(vcode)
    case vcode.code
    when 0x00..0x07
      vcode.address = vcode.code
      vcode.location = :registers
    when 0x08..0x0F
      vcode.address = @registers[vcode.code - 8].to_i
    when 0x10..0x17
      vcode.address = next_word.to_i + @registers[vcode.code - 10].to_i
    when 0x18
      vcode.location = :pop
    when 0x19
      vcode.location = :peek
    when 0x1A
      vcode.location = :push
    when 0x1B
      vcode.location = :sp
    when 0x1C
      vcode.location = :pc
    when 0x1D
      vcode.location = :overflow
    when 0x1E
      vcode.address = next_word.to_i
    when 0x1F
      vcode.location = :next_word
    when 0x20..0x3F
      vcode.location = :literal
      vcode.value = vcode.code - 0x20
    else
      raise "Invalid value code"
    end
  end
end