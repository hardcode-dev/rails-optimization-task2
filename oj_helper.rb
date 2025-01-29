module OjHelper

  def init_stream(file)
    @stream = Oj::StreamWriter.new(file)
  end

  def push_object
    @stream.push_object
    yield
    @stream.pop
  end

  def push_key(key)
    @stream.push_key(key)
  end

  def push_value(value)
    @stream.push_value(value)
  end

  def push_pair(key, value)
    @stream.push_key(key)
    if value.is_a? Array
      push_array(value)
    else
      @stream.push_value(value)
    end
  end

  def push_array(array)
    @stream.push_array
    array.each { |e| @stream.push_value(e) }
    @stream.pop
  end

  def flush
    @stream.flush
  end

end
