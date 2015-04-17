require "test/unit"
require "obuf"
require "flexmock"
require "flexmock/test_unit"
require "stringio"

# We are limited to flexmock 0.8 on Ruby 1.8
# http://redmine.ruby-lang.org/issues/4882
# https://github.com/jimweirich/flexmock/issues/4
# https://github.com/julik/flexmock/commit/4acea00677e7b558bd564ec7c7630f0b27d368ca
class FlexMock::PartialMockProxy
  def singleton?(method_name)
    @obj.singleton_methods.include?(method_name.to_s)
  end
end

class TestObuf < Test::Unit::TestCase
  
  def test_accumulator_saves_objs
    a = Obuf.new
    values = [3, {:foo => "bar"}, "foo"]
    values.map(&a.method(:push))
    
    assert_equal 3, a.size
    assert_equal values, a.map{|e| e }, "Should return the same elements from the storage"
  end
  
  def test_initialize_with_block
    o = Obuf.new do | buf |
      buf.push("Excitement!")
    end
    
    assert_equal 1, o.size
    assert_equal %w( Excitement! ), o.to_a
  end
   
  def test_from_enum
    a = Obuf.new([1,2,3])
    assert_equal [1,2,3], a.to_a
  end
  
  def test_accumulator_saves_shitload_of_objs
    a = Obuf.new
    50_000.times { a.push("A string" => rand) }
    assert_equal 50_000, a.size
  end
  
  def test_accumulator_saves_few_strings_with_a_tab
    a = Obuf.new
    4.times { a.push("A \tstring") }
    a.each {|e| assert_equal "A \tstring", e }
  end
  
  def test_accumulator_empty
    a = Obuf.new
    assert a.empty?
    a.push(1)
    assert !a.empty?
  end
  
  def test_accumulator_supports_nested_iteration
    a = Obuf.new
    ("A".."Z").each{|e| a << e}
    
    accumulated = []
    seen_g = false
    a.each do | first_level |
      if first_level == "G"
        seen_g = true
        # Force a nested iteration and break it midway
        a.each do | second_level |
          accumulated.push(second_level)
          break if second_level == "E"
        end
      elsif seen_g
        assert_equal "H", first_level
        return
      end
    end
  end
  
  def test_random_access
    a = Obuf.new
    letters = ("A".."Z").map{|e| "#{e}\r\nWow!"}.to_a
    letters.map(&a.method(:push))
    
    assert_equal "B\r\nWow!", a[1]
    assert_equal "E\r\nWow!", a[4]
  end
  
  def test_random_access_out_of_bounds
    a = Obuf.new
    letters = ("A".."Z").map{|e| "#{e}\r\nWow!"}.to_a
    letters.map(&a.method(:push))
    assert_equal nil, a[27]
    
    b = Obuf.new
    assert_nil b[0]
    assert_nil b[-1]
  end
  
  def test_clear_calls_close_on_buffer
    io = Tempfile.new("testing")
    flexmock(io).should_receive(:close!).once
    flexmock(Tempfile).should_receive(:new).once.with("obuf").and_return(io)
    
    a = Obuf.new
    40.times { a.push("A string" => rand) }
    assert_equal 40, a.size
    a.clear
    assert_equal 0, a.size
  end
end

class TestLens < Test::Unit::TestCase
  def test_lens_write
    mock_io = flexmock()
    lens = Obuf::Lens.new(mock_io)
    flexmock(mock_io).should_receive(:write).with(19)
    flexmock(mock_io).should_receive(:write).with("\t")
    flexmock(mock_io).should_receive(:write).with("\x04\bI\"\x0EHi there!\x06:\x06ET")
    flexmock(mock_io).should_receive(:write).with("\n")
    lens << "Hi there!"
  end
  
  def test_lens_recover_object_after_write
    mock_io = StringIO.new
    lens = Obuf::Lens.new(mock_io)
    lens << "Hi there!"
    
    recovered = lens.recover_object
    assert_nil recovered, "The IO is at the end now"
    
    mock_io.rewind
    recovered = lens.recover_object
    assert_equal "Hi there!", recovered
  end
  
  def test_lens_each
    mock_io = StringIO.new
    
    writing_lens = Obuf::Lens.new(mock_io)
    writing_lens << "Hi there!"
    writing_lens << 98121
    writing_lens << [123, :a]
    
    mock_io.rewind
    
    reading_lens = Obuf::Lens.new(mock_io)
    items = []
    reading_lens.each do | item |
      items << item
    end
    
    assert_equal "Hi there!", items[0]
    assert_equal 98121, items[1]
    assert_equal [123, :a], items[2]
  end
  
  def test_lens_recover_at
    mock_io = StringIO.new
    
    writing_lens = Obuf::Lens.new(mock_io)
    writing_lens << "Hi there!"
    writing_lens << 98121
    writing_lens << [123, :a]
    
    reading_lens = Obuf::Lens.new(mock_io)
    # Also try to recover object at index 3, which does not exist in the underlying buffer
    objects_at_positions = (0..3).to_a.reverse.map do | i |
      reading_lens.recover_at(i)
    end
    
    assert_nil objects_at_positions[0]
    assert_equal [123, :a], objects_at_positions[1]
    assert_equal 98121, objects_at_positions[2]
    assert_equal "Hi there!", objects_at_positions[3]
  end
  
end
