require_relative 'lib/assembler'
require_relative 'lib/dcpu'

assembler = Assembler.new
file = "#{ARGV.first}.o"
assembler.assemble ARGF
assembler.dump file

dcpu = DCPU.new file
dcpu.program_size = assembler.body.size
dcpu.start