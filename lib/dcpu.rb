require_relative 'memory'
require_relative 'instruction'

class DCPU
  attr_accessor :program_size
  attr_reader :pc, :registers, :memory, :sp
  REGISTERS = %w{A B C X Y Z I J}.map!(&:to_sym)
      
  def initialize(file)
    @pc, @overflow, @cycle = 0, 0, 0
    @sp = 0xffff
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
    @sp -= 1
    @memory[@sp] = value
  end

  def pop
    value = peek
    @sp += 1
    value
  end

  def peek
    self[@sp]
  end
  
  def start
    @program_size.times { process(next_word) }
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
      instruction.a = word.upper_six
    else
      instruction = BasicInstruction.new(opcode, self)
      instruction.a = word.lower_six
      instruction.b = word.upper_six
    end
    instruction.execute
  end
  
  def get_value(code)
    case code
    when 0x00..0x07
      @registers[code]
    when 0x08..0x0F
      self[@registers[code - 0x08].to_dec]
    when 0x10..0x17
      self[next_word.to_dec + @registers[code - 0x10].to_dec]
    when 0x18
      pop
    when 0x19
      peek
    when 0x1B
      @sp
    when 0x1C
      @pc
    when 0x1D
      @overflow
    when 0x1E
      self[next_word]
    when 0x1F
      next_word
    when 0x20..0x3F
      code - 0x20
    else
      raise "Invalid value code"
    end
  end
  
  def set_value(code, value)
    case code
    when 0x00..0x07
      @registers[code] = value
    when 0x08..0x0F
      self[@registers[code - 0x08].to_dec] = value
    when 0x10..0x17
      self[next_word.to_dec + @registers[code - 0x10].to_dec] = value
    when 0x1A
      push value
    when 0x1B
      @sp = value
    when 0x1C
      @pc = value
    when 0x1D
      @overflow = value
    when 0x1E
      self[next_word] = value
    when 0x1F
      next_word
    when 0x20..0x3F
      code - 0x20
    else
      raise "Invalid value code"
    end
  end
end