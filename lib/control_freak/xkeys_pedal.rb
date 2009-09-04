class XkeysPedal
  INACTIVE_FLAGS = 256
  LEFT_CODE = 59
  MIDDLE_CODE = 61
  RIGHT_CODE =65
  attr_reader :device

  def initialize
    @device = DDHidKeyboard.allKeyboards.find {|k| k.properties['Product'] == 'Xkeys'}
    device.listenInExclusiveMode = true
    device.startListening

    at_exit do
      device.stopListening if device.isListening
    end

    @active_left_flags = INACTIVE_FLAGS
    @active_middle_flags = INACTIVE_FLAGS
    @active_right_flags = INACTIVE_FLAGS
  end

  attr_accessor :left_flags, :middle_flags, :right_flags, :active_left_flags, :active_middle_flags, :active_right_flags

  def left_flags=(flags)
    on_left_down do
      @active_left_flags = flags
    end

    on_left_up do
      @active_left_flags = INACTIVE_FLAGS
    end
  end

  def middle_flags=(flags)
    on_middle_down do
      @active_middle_flags = flags
    end

    on_middle_up do
      @active_middle_flags = INACTIVE_FLAGS
    end
  end

  def right_flags=(flags)
    on_right_down do
      p "right"
      @active_right_flags = flags
    end

    on_right_up do
      @active_right_flags = INACTIVE_FLAGS
    end
  end

  def active_flags
    INACTIVE_FLAGS | active_left_flags | active_right_flags | active_middle_flags
  end

  def on_left_down(&proc)
    device.on_key_down do |code|
      if code == LEFT_CODE
        proc.call
      end
    end
  end

  def on_left_up(&proc)
    device.on_key_up do |code|
      if code == LEFT_CODE
        proc.call
      end
    end
  end

  def on_middle_down(&proc)
    device.on_key_down do |code|
      if code == MIDDLE_CODE
        proc.call
      end
    end
  end

  def on_middle_up(&proc)
    device.on_key_up do |code|
      if code == MIDDLE_CODE
        proc.call
      end
    end
  end

  def on_right_down(&proc)
    device.on_key_down do |code|
      if code == RIGHT_CODE
        proc.call
      end
    end
  end

  def on_right_up(&proc)
    device.on_key_up do |code|
      if code == RIGHT_CODE
        proc.call
      end
    end
  end
end
