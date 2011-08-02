require "test/unit"
require "obuf"
require "flexmock"
require "flexmock/test_unit"

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
