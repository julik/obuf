require "tempfile"
require "thread" # required for ruby 18

# An object buffer for Ruby objects. Use it to sequentially store a shitload
# of objects on disk and then retreive them one by one. Make sure to call clear when done
# with it to discard the stored blob. 
#
#  a = Obuf.new
#  parse_big_file do | one_node |
#    a.push(one_node)
#  end
#
#  a.size #=> 30932 # We've stored 30 thousand objects on disk without breaking a sweat
#  a.each do | node_read_from_disk |
#     # do something with node that has been recovered from disk
#  end
#
#  a.clear # ensure that the file is deleted
#
# Both reading and writing aim to be threadsafe
class Obuf
  VERSION = "1.2.0"
  require File.dirname(__FILE__) + "/obuf/lens"
  require File.dirname(__FILE__) + "/obuf/protected_lens"
  
  include Enumerable
  
  # Returns the number of objects stored so far
  attr_reader :size
  
  # Initializes a new Obuf. If an Enumerable argument is passed each element from the
  # Enumerable will be stored in the Obuf (so you can pass an IO for example)
  def initialize(enumerable = [])
    @sem = Mutex.new
    @store = Tempfile.new("obuf")
    @store.binmode
    @size = 0
    
    @lens = Obuf::ProtectedLens.new(@store)
    
    # Store everything from the enumerable in self
    enumerable.each { |e| push(e) }
    
    # ...and yield self for any configuration
    yield self if block_given?
  end
  
  # Tells whether the buffer is empty
  def empty?
    @size.zero?
  end
  
  # Store an object
  def push(object_to_store)
    @sem.synchronize {
      @lens << object_to_store
      @size += 1
    }
    object_to_store
  end
  
  alias_method :<<, :push
  
  # Retreive each stored object in succession. All other Enumerable
  # methods are also available (but be careful with Enumerable#map and to_a)
  def each
    with_separate_read_io do | iterable |
      reading_lens = Obuf::Lens.new(iterable)
      @size.times { yield(reading_lens.recover_object) }
    end
  end
  
  # Calls close! on the datastore and deletes the objects in it
  def clear
    @sem.synchronize do
      @store.close!
      @size = 0
    end
  end
  
  # Retreive a slice of the enumerable at index
  def [](slice)
    slice.respond_to?(:each) ? slice.map{|i| recover_at(i) } : recover_at(slice)
  end
  
  private
  
  def recover_at(idx)
    with_separate_read_io do | iterable |
      reading_lens = Obuf::Lens.new(iterable)
      reading_lens.recover_at(idx)
    end
  end
  
  # We first ensure that we have a disk-backed file, then reopen it as read-only
  # and iterate through that (we will have one IO handle per loop nest)
  def with_separate_read_io
    # Ensure all data is written before we read it
    iterable = @sem.synchronize do
      @store.flush
      File.open(@store.path, "rb")
    end
    
    begin
      yield(iterable)
    ensure
      iterable.close
    end
  end
end
