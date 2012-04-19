require_relative 'test_helper'

class DCPUTest < Test::Unit::TestCase
  def test_initialize
    dcpu = DCPU.new 'test_examples/test.s.o'
    assert_equal(0, dcpu.pc)
    assert_equal(0, dcpu.registers[:A])
    assert_equal(0, dcpu.registers[:J])
    assert_equal(256, dcpu.memory.size)
    assert_equal("|\x01", dcpu.memory[0])
    assert_equal("\x00\x00", dcpu.memory[255])
  end
end