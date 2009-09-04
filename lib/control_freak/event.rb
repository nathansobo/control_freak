class Event
  def set_event_source(source)
    CGEventSetSource(eventRef, source)
  end

  def set_keycode(code)
    set_integer_value_field(KCGKeyboardEventKeycode, code)
  end

  def keycode
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

  def get_flags
    CGEventGetFlags(eventRef)  
  end
end
