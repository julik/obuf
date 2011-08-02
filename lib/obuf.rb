require "tempfile"

# An object buffer for Ruby objects. Use it to sequentially store a shitload
# of objects on disk and then retreive them one by one. Make sure to call clear when done
# with it to discard the stored blob. It can be used like a disk-based object buffer.
# (Tracksperanto stores parsed trackers into it)
#
#  a = Tracksperanto::Accumulator.new
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
# Both reading and writing aim to be threadsafe (writing operations will be locked with a mutex, and )
class Obuf
  VERSION = "1.0.0"
  
  include Enumerable
  
  DELIM = "\t"
  END_RECORD = "\n"
  
  # Returns the number of objects stored so far
  attr_reader :size
  
  def initialize
    @sem = Mutex.new
    @store = create_store
    @store.set_encoding(Encoding::BINARY) if @store.respond_to?(:set_encoding)
    @store.binmode
    
    @size = 0
    super
  end
  
  # Tells whether the buffer is empty
  def empty?
    @size.zero?
  end
  
  # Store an object
  def push(object_to_store)
    blob = marshal_object(object_to_store)
    @sem.synchronize do
      @store.write(blob.size)
      @store.write(DELIM)
      @store.write(blob)
      @store.write(END_RECORD)
      @size += 1
    end
    object_to_store
  end
  
  alias_method :<<, :push
  
  # Retreive each stored object in succession. All other Enumerable
  # methods are also available (but be careful with Enumerable#map and to_a)
  def each
    with_separate_read_io do | iterable |
      @size.times { yield(recover_object_from(iterable)) }
    end
  end
  
  # Calls close! on the datastore and deletes the objects in it
  def clear
    @store.close!
    @size = 0
  end
  
  # Retreive a concrete object at index
  def [](idx)
    idx.respond_to?(:each) ? idx.map{|i| recover_at(i) } : recover_at(idx)
  end
  
  private
  
  def recover_at(idx)
    with_separate_read_io do | iterable |
      iterable.seek(0)
      
      # Do not unmarshal anything but wind the IO in fixed offsets
      idx.times do
        skip_bytes = iterable.gets("\t").to_i
        iterable.seek(iterable.pos + skip_bytes)
      end
      
      recover_object_from(iterable)
    end
  end
  
  # We first ensure that we have a disk-backed file, then reopen it as read-only
  # and iterate through that (we will have one IO handle per loop nest)
  def with_separate_read_io
    # Ensure all data is written before we read it
    @sem.synchronize { @store.flush }
    
    iterable = File.open(@store.path, "r")
    begin
      yield(iterable)
    ensure
      iterable.close
    end
  end
  
  def marshal_object(object_to_store)
    d = Marshal.dump(object_to_store)
  end
  
  def recover_object_from(io)
    # Up to the tab is the amount of bytes to read
    demarshal_bytes = io.gets("\t").to_i
    blob = io.read(demarshal_bytes)
    
    Marshal.load(blob)
  end
  
  # In case you need to use something else (say, a StringIO)
  def create_store
    Tempfile.new("obuf")
  end
end
