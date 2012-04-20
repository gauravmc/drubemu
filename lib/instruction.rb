class BasicInstruction
  attr_accessor :a, :b

  ALL = Hash[(1..15).to_a.zip(%w{SET ADD SUB MUL DIV MOD SHL SHR AND BOR XOR IFE IFN IFG IFB}.map(&:to_sym).flatten)]
  
  def initialize(opcode, cpu)
    @opcode = ALL[opcode]
    @cpu = cpu
  end
  
  def execute
    case @opcode
    when :SET
      set @a, get_value(@b)
    else
      raise "Invalid opcode: #{@opcode}"
    end
  end
  
  def set(a, b)
    @cpu.set_value(a, b)
  end
  
  def get_value(a)
    @cpu.get_value(a)
  end
end

# class NonBasicInstruction
#   attr_reader :opcode, :a
# 
#   ALL = Hash[(0..1).to_a.zip(%w{Reserved JSR}.map(&:to_sym).flatten)]
#   
#   def initialize(opcode, cpu)
#     @opcode = ALL[opcode]
#     @cpu
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