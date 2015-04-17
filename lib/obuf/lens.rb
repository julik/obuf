require 'thread'

# Provides a per-object iterator on top of any IO object or pipe
class Obuf::Lens
  include Enumerable
  NothingToRecover = Class.new(StandardError)
  
  DELIM = "\t"
  END_RECORD = "\n"
  
  # Creates a new Lens on top of a File object, IO object or pipe.
  # The object given should support +seek+, +gets+, and +read+ to recover
  # objects, and +write+ to dump objects.
  def initialize(io_or_pipe)
    @io = io_or_pipe
  end
  
  # Store an object
  def <<(object_to_store)
    blob = marshal_object(object_to_store)
    @io.write(blob.size)
    @io.write(DELIM)
    @io.write(blob)
    @io.write(END_RECORD)
    object_to_store
  end
  
  # Recover Nth object
  def recover_at(idx)
    @io.seek(0)
    # Do not unmarshal anything but wind the IO in fixed offsets
    idx.times do
      skip_bytes = @io.gets("\t").to_i
      @io.seek(@io.pos + skip_bytes + 1)
    end
    
    recover_object
  rescue NothingToRecover # TODO: we need to honor this exception in the future
    nil
  end
  
  # Recover the object at the current position in the IO. Returns +nil+
  # if there is nothing to recover or the backing buffer is empty.
  def recover_object
    # Up to the tab is the amount of bytes to read
    demarshal_bytes = @io.gets("\t").to_i
    
    # When at end of IO return nil
    raise NothingToRecover if demarshal_bytes.zero?
    
    blob = @io.read(demarshal_bytes)
    demarshal_object(blob)
  end
  
  def each
    begin
      loop { yield(recover_object) }
    rescue NothingToRecover
    end
  end
  
  private
  
  # This method is only used internally. 
  # Override this if you need non-default marshalling 
  # (don't forget to also override demarshal_object)
  def marshal_object(object_to_store)
    Marshal.dump(object_to_store)
  end
  
  # This method is only used internally. 
  # Override this if you need non-default demarshalling
  # (don't forget to also override marshal_object)
  def demarshal_object(blob)
    Marshal.load(blob)
  end
end
