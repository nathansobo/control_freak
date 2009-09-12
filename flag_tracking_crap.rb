  LeftControl = 0xE0
  RightControl = 0xE4
  CapsLock = 0x39

  LeftShift = 0xE1
  RightShift = 0xE5

  LeftAlt = 0xE2
  RightAlt = 0xE6

  LeftCommand = 0xE3
  RightCommand = 0xE7

  def track_modifier_keys
    on_key_down do |keycode|
      $usage_map.usb_usage = keycode

      case keycode
        when LeftControl, RightControl, CapsLock
          control_on
        when LeftShift, RightShift
          shift_on
        when LeftAlt, RightAlt
          alt_on
        when LeftCommand, RightCommand
          command_on
      end
    end

    on_key_up do |keycode|
      case keycode
        when LeftControl, RightControl, CapsLock
          control_off
        when LeftShift, RightShift
          shift_off
        when LeftAlt, RightAlt
          alt_off
        when LeftCommand, RightCommand
          command_off
      end
    end

    startListening
  end

  NO_FLAGS_MASK = 256

  def control_on
    @control_on = true
  end

  def control_off
    @control_on = false
  end

  def control_on?
    @control_on
  end

  def control_mask
    control_on?? KCGEventFlagMaskControl : NO_FLAGS_MASK
  end

  def shift_on
    @shift_on = true
  end

  def shift_off
    @shift_on = false
  end

  def shift_on?
    @shift_on
  end

 def shift_mask
    shift_on?? KCGEventFlagMaskShift : NO_FLAGS_MASK
  end

  def alt_on
    @alt_on = true
  end

  def alt_off
    @alt_on = false
  end

  def alt_on?
    @alt_on
  end

  def alt_mask
    alt_on?? KCGEventFlagMaskAlternate : NO_FLAGS_MASK
  end

  def command_on
    @command_on = true
  end

  def command_off
    @command_on = false
  end

  def command_on?
    @command_on
  end

  def command_mask
    command_on?? KCGEventFlagMaskCommand : NO_FLAGS_MASK
  end

  def flags
    control_mask | shift_mask | alt_mask | command_mask | NO_FLAGS_MASK
  end

  def on_key_down(&proc)
    key_down_node.subscribe(&proc)
  end

  def on_key_up(&proc)
    key_up_node.subscribe(&proc)
  end

  attr_accessor :delegate
