require_relative 'lib/assembler'
require_relative 'lib/dcpu'

assembler = Assembler.new
file = "#{ARGV.first}.o"
assembler.assemble ARGF
assembler.dump file

dcpu = DCPU.new file
dcpu.program_size = assembler.data_size
dcpu.run
dcpu.registers.each {|k,v| puts "#{DCPU::REGISTERS[k]}: #{v.to_hex}"}
puts "PC: #{dcpu.pc}"
puts dcpu.memory.first(30).inspect