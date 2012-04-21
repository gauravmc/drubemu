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
    a = @a.process.value
    b = @b.process.value
    
    case @opcode
    when :SET
      @cpu.cycle += 1
      set @a, b
      
    when :ADD
      @cpu.cycle += 1
      sum = a + b
      @cpu.overflow = sum > 0xFFFF ? 1 : 0
      set @a, sum
      
    when :SUB
      @cpu.cycle += 1
      res = a - b
      @cpu.overflow = res < 0 ? 0xFFFF : 0
      set @a, res
      
    when :MUL
      @cpu.cycle += 2
      res = a * b
      @cpu.overflow = ((a * b) >> 16) & 0xFFFF
      set @a, res

    when :DIV
      @cpu.cycle += 3
      _a, _b = a, b
      if _b == 0
        @cpu.overflow, res = 0, 0
      else
        res = _a / _b
        @cpu.overflow = ((_a << 16) / _b) & 0xFFFF
      end
      set @a, res

    when :MOD
      @cpu.cycle += 3
      _a, _b = a, b
      if b == 0
        res = 0
      else
        res = a % b
      end
      set @a, res

    when :SHL
      @cpu.cycle += 2
      res = a << b
      @cpu.overflow = ((a << b) >> 16) & 0xFFFF
      set @a, res

    when :SHR
      @cpu.cycle += 2
      res = a >> b
      @cpu.overflow = ((a << 16) >> b) & 0xFFFF
      set @a, res

    when :AND
      @cpu.cycle += 1
      res = a & b
      set @a, res

    when :BOR
      @cpu.cycle += 1
      res = a | b
      set @a, res

    when :XOR
      @cpu.cycle += 1
      res = a ^ b
      set @a, res

    when :IFE
      @cpu.cycle += 2
      @cpu.cycle += 1 and @cpu.skip unless a == b

    when :IFN
      @cpu.cycle += 2
      @cpu.cycle += 1 and @cpu.skip unless a != b

    when :IFG
      @cpu.cycle += 2
      @cpu.cycle += 1 and @cpu.skip unless a >= b

    when :IFB
      @cpu.cycle += 2
      @cpu.cycle += 1 and @cpu.skip unless (a & b) != 0
      
    else
      raise "Invalid opcode: #{@opcode}"
    end
  end
  
end

# class NonBasicInstruction
#   attr_accessor :a
# 
#   ALL = Hash[(0..1).to_a.zip(%w{Reserved JSR}.map(&:to_sym).flatten)]
#   
#   def initialize(opcode, cpu)
#     @opcode = ALL[opcode]
#     @cpu = cpu
#   end
#   
#   def execute
#     case @opcode
#     when :JSR
#       
#     else
#       raise "Invalid opcode: #{@opcode}"
#     end
#   end
# end