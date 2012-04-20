require_relative 'test_helper'

class DCPUTest < Test::Unit::TestCase
  def setup
    @dcpu = DCPU.new 'test_examples/test.s.o'    
  end
  
  def test_initialize
    assert_equal(0, @dcpu.pc)
    assert_equal("\x00\x00", @dcpu.registers[1])
    assert_equal("\x00\x00", @dcpu.registers[5])
    assert_equal(65536, @dcpu.memory.size)
    assert_equal("|\x01", @dcpu.memory[0])
    assert_equal("\x00\x00", @dcpu.memory[255])
  end
  
  def test_square_brackets
    assert_equal(@dcpu[1], @dcpu.memory[1])
    assert_equal(@dcpu[25], @dcpu.memory[25])
    assert_equal(@dcpu[200], @dcpu.memory[200])
  end
  
  def test_pop_push_peek
    assert_equal(0xffff, @dcpu.sp)
    
    @dcpu.push "value"
    assert_equal(0xfffe, @dcpu.sp)
    assert_equal(@dcpu[0xfffe], "value")
    
    assert_equal("value", @dcpu.peek)
    assert_equal(0xfffe, @dcpu.sp)
    
    assert_equal("value", @dcpu.pop)
    assert_equal(0xffff, @dcpu.sp)
  end
end