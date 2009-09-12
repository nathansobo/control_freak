class Event
  def set_event_source(source)
    CGEventSetSource(eventRef, source)
  end

  def type
    CGEventGetType(eventRef)
  end

  def key_down?
    type == KCGEventKeyDown
  end

  def key_code=(key_code)
    set_integer_value_field(KCGKeyboardEventKeycode, key_code)
  end

  def key_code
    get_integer_value_field(KCGKeyboardEventKeycode)
  end

  def set_integer_value_field(field, value)
    CGEventSetIntegerValueField(eventRef, field, value)
  end

  def get_integer_value_field(field)
    CGEventGetIntegerValueField(eventRef, field)
  end

  def get_user_data
    CGEventGetIntegerValueField(eventRef, KCGEventSourceUnixProcessID)
  end

  def flags
    CGEventGetFlags(eventRef)  
  end

  def flags=(flags)
    CGEventSetFlags(eventRef, flags)
  end
end
