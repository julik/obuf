require 'thread'

# Similar to Obuf::Lens but protects all the operations that change the IO offset
# with a Mutex.
class Obuf::ProtectedLens < Obuf::Lens
  def initialize(io)
    super
    @mutex = Mutex.new
  end
  
  # Store an object
  def <<(object_to_store)
    @mutex.synchronize { super }
  end
  
  def recover_at(idx)
    @mutex.synchronize { super }
  end
  
  def recover_object
    @mutex.synchronize { super }
  end
end