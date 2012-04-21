require_relative 'helpers/conversion_helper'

class Instruction

  class ValueCode
    attr_accessor :address, :value, :location, :code
  
    include ConversionHelper
  
    def initialize(cpu)
      @cpu = cpu
      @location = :memory
    end
  
    def process
      @cpu.process_value self
      self
    end
  
    def value
      case @location
      when :memory
        @cpu.memory[@address].to_i
      when :registers
        @cpu.registers[@address].to_i
      when :pop
        @cpu.pop.to_i
      when :peek
        @cpu.peek.to_i
      when :sp
        @cpu.sp
      when :pc
        @cpu.pc
      when :overflow
        @cpu.overflow
      when :next_word
        @location = :memory
        @address = @cpu.pc
        @cpu.next_word.to_i
      else
        @value
      end
    end
      
    def set(value)
      case @location
      when :memory
        @cpu.memory[@address] = to_bindata(value)
      when :registers
        @cpu.registers[@address] = to_bindata(value)
      when :push
        @cpu.push to_bindata(value)
      when :sp
        @cpu.sp = to_i to_bindata(value)
      when :pc
        @cpu.pc = to_i to_bindata(value)
      when :overflow
        @cpu.overflow = to_i to_bindata(value)
      end
    end
  end
  
end