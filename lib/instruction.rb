require_relative 'value_code'

class Instruction
  include ConversionHelper
  
  def set(a, b)
    a.set b
  end
end

class BasicInstruction < Instruction
  attr_accessor :a, :b

  ALL = Hash[(1..15).to_a.zip(%w{SET ADD SUB MUL DIV MOD SHL SHR AND BOR XOR IFE IFN IFG IFB}.map(&:to_sym).flatten)]
    
  def initialize(opcode, cpu)
    @opcode = ALL[opcode]
    @cpu = cpu
    @a, @b = ValueCode.new(@cpu), ValueCode.new(@cpu)
  end
    
  def execute
    _a = @a.process.value
    _b = @b.process.value
        
    a = _a.to_i
    b = _b.to_i
    
    case @opcode
    when :SET
      @cpu.cycle += 1
      set @a, _b
      
    when :ADD
      @cpu.cycle += 1
      res = a + b
      @cpu.overflow = res > 0xFFFF ? 1 : 0
      
    when :SUB
      @cpu.cycle += 1
      res = a - b
      @cpu.overflow = res < 0 ? 0xFFFF : 0
      
    when :MUL
      @cpu.cycle += 2
      res = a * b
      @cpu.overflow = ((a * b) >> 16) & 0xFFFF
    
    when :DIV
      @cpu.cycle += 3
      if b == 0
        @cpu.overflow, res = 0, 0
      else
        res = a / b
        @cpu.overflow = ((a << 16) / b) & 0xFFFF
      end
    
    when :MOD
      @cpu.cycle += 3
      if b == 0
        res = 0
      else
        res = a % b
      end
    
    when :SHL
      @cpu.cycle += 2
      res = a << b
      @cpu.overflow = ((a << b) >> 16) & 0xFFFF
    
    when :SHR
      @cpu.cycle += 2
      res = a >> b
      @cpu.overflow = ((a << 16) >> b) & 0xFFFF
    
    when :AND
      @cpu.cycle += 1
      res = a & b
    
    when :BOR
      @cpu.cycle += 1
      res = a | b
    
    when :XOR
      @cpu.cycle += 1
      res = a ^ b
    
    when :IFE
      @cpu.cycle += 2
      @cpu.pc += 2 unless a == b
    
    when :IFN
      @cpu.cycle += 2
      @cpu.pc += 2 unless a != b
    
    when :IFG
      @cpu.cycle += 2
      @cpu.pc += 2 unless a >= b
    
    when :IFB
      @cpu.cycle += 2
      @cpu.pc += 2 unless (a & b) != 0
      
    else
      raise "Invalid opcode: #{@opcode}"
    end
    
    set @a, to_bindata(res) if res.is_a? Integer
  end
  
end

class NonBasicInstruction < Instruction
  attr_accessor :a

  ALL = Hash[[1].to_a.zip(%w{JSR}.map(&:to_sym).flatten)]
    
  def initialize(opcode, cpu)
    @opcode = ALL[opcode]
    @cpu = cpu
    @a = ValueCode.new(@cpu)
  end
    
  def execute
    _a = @a.process.value
    a = _a.to_i
    
    case @opcode
    when :JSR
      @cpu.push @pc
      @cpu.pc = a
    else
      raise "Invalid opcode: #{@opcode}"
    end
  end
end