require_relative 'test_helper'

class MemoryTest < Test::Unit::TestCase
  def setup
    @sample_memory_data = ["|\x01", "\x000", "}\xE1", "\x10\x00", "\x00 "]
  end
  
  def test_initialize
    memory = Memory.new @sample_memory_data
    assert_equal(65536, memory.size)
    assert_equal("|\x01", memory[0])
    assert_equal("\x10\x00", memory[3])
    assert_equal("\x00\x00", memory[5])
    assert_equal(Memory::Word, memory[23].class)
  end
    
  class WordTest < Test::Unit::TestCase
    def test_to_hex_to_dec_to_bin
      word = Memory::Word.new("|\x01")
      assert_equal("7c01", word.to_hex)
      assert_equal(31745, word.to_dec)
      assert_equal("0111110000000001", word.to_bin)
    end
    
    def test_bit_chops
      word = Memory::Word.new("|\x01")
      assert_equal(1, word.lower_four)
      assert_equal(0, word.lower_six)
      assert_equal(31, word.upper_six)
    end
  end
end