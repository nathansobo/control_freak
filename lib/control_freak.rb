dir = File.dirname(__FILE__)

require "#{dir}/control_freak/subscription_node"
framework "ApplicationServices"
framework "#{dir}/../DDHidLib.framework"
require "#{dir}/control_freak/ddhid_keyboard"
require "#{dir}/control_freak/xkeys_pedal"
require "#{dir}/control_freak/event_tap"
require "#{dir}/control_freak/event"


def puts_binary(n)
  puts n.to_s(2).rjust(32, '0')
end

require 'hotcocoa'

module HasEventTransformers
  def add_transformer(transformer)
    transformers.push(transformer)
  end

  def transformers
    @transformers ||= []
  end

  def transform(event)
    transformers.inject(event) do |event, transformer|
      transformer.key_down(event) if event
    end
  end
end

class PhysicalKeyboard
  include HasEventTransformers

  def self.all
    DDHidKeyboard.allKeyboards.map do |hid_keyboard|
      PhysicalKeyboard.new(hid_keyboard)
    end
  end

  attr_reader :hid_keyboard, :key_down_node, :key_up_node, :on_next_input_handler

  def initialize(hid_keyboard)
    @hid_keyboard = hid_keyboard
    hid_keyboard.delegate = self
    @key_down_node = SubscriptionNode.new
    @key_up_node = SubscriptionNode.new
  end

  def on_next_input(&proc)
    @on_next_input_handler = proc
  end

  def listen
    hid_keyboard.startListening
  end

  def seize
    hid_keyboard.listenInExclusiveMode = true
    listen
  end

  def key_down(code)
    if on_next_input_handler
      on_next_input_handler.call
      @on_next_input_handler = nil
    end
    event = KeyboardEvent.alloc.initWithHIDUsageCode(code, keyDown:true)
    transformed_event = transform(event)
    key_down_node.publish(transformed_event) if transformed_event
  end

  def key_up(code)
    if on_next_input_handler
      on_next_input_handler.call
      @on_next_input_handler = nil
    end
    event = KeyboardEvent.alloc.initWithHIDUsageCode(code, keyDown:false)
    transformed_event = transform(event)
    key_up_node.publish(transformed_event) if transformed_event
  end

  def on_key_down(&proc)
    key_down_node.subscribe(&proc)
  end

  def on_key_up(&proc)
    key_up_node.subscribe(&proc)
  end
end

class VirtualKeyboard
  include HasEventTransformers

  attr_reader :input_keyboards, :event_tap, :transformers

  def initialize(input_keyboards)
    @input_keyboards = input_keyboards
    @transformers = []
    @event_tap = EventTap.alloc.init

    input_keyboards.each do |keyboard|
      keyboard.on_key_down do |event|
        key_down(event)
      end

      keyboard.on_key_up do |event|
        key_up(event)
      end
      keyboard.seize
    end
  end

  def key_down(event)
    transformed_event = transform(event)
    event_tap.postEvent(transformed_event) if transformed_event
  end

  def key_up(event)
    transformed_event = transformers.inject(event) do |event, transformer|
      transformer.key_up(event) if event
    end

    event_tap.postEvent(transformed_event) if transformed_event
  end
end

class FlagTracker
  LeftControl = 59
  RightControl = 62
  CapsLock = 57

  LeftShift = 56
  RightShift = 60

  LeftAlt = 58
  RightAlt = 61

  LeftCommand = 55
  RightCommand = 54

  NO_FLAGS_MASK = 256

  attr_reader :control_flags, :shift_flags, :alt_flags, :command_flags

  def initialize
    @control_flags = NO_FLAGS_MASK
    @shift_flags = NO_FLAGS_MASK
    @alt_flags = NO_FLAGS_MASK
    @command_flags = NO_FLAGS_MASK
  end

  def key_down(event)
    case event.key_code
      when LeftControl, RightControl, CapsLock
        @control_flags = KCGEventFlagMaskControl
        nil
      when LeftShift, RightShift
        @shift_flags = KCGEventFlagMaskShift
        nil
      when LeftAlt, RightAlt
        @alt_flags = KCGEventFlagMaskAlternate
        nil
      when LeftCommand, RightCommand
        @command_flags = KCGEventFlagMaskCommand
        nil
      else
        event.flags = flags
        event
    end
  end

  def key_up(event)
    case event.key_code
      when LeftControl, RightControl, CapsLock
        @control_flags = NO_FLAGS_MASK
        nil
      when LeftShift, RightShift
        @shift_flags = NO_FLAGS_MASK
        nil
      when LeftAlt, RightAlt
        @alt_flags = NO_FLAGS_MASK
        nil
      when LeftCommand, RightCommand
        @command_flags = NO_FLAGS_MASK
        nil
      else
        event.flags = flags
        event
    end
  end

  def flags
    flags = control_flags | shift_flags | alt_flags | command_flags | NO_FLAGS_MASK
  end
end

class KeyRemapper
  attr_reader :mapping

  def initialize(mapping)
    @mapping = mapping
  end

  def key_down(event)
    remap(event)
  end

  def key_up(event)
    remap(event)
  end

  def remap(event)
    if remapped_key_code = mapping[event.key_code]
      event.key_code = remapped_key_code
    end
    event
  end
end

class KeyCodePrinter
  def key_down(event)
    p event.key_code
    event
  end

  def key_up(event)
    event
  end
end

class DoubleKeyboard
  attr_reader :physical_keyboards, :virtual_keyboard, :left_keyboard

  def initialize
    @physical_keyboards = PhysicalKeyboard.all

    physical_keyboards.each do |keyboard|
      keyboard.on_next_input do
        self.left_keyboard ||= keyboard
      end
    end

    @virtual_keyboard = VirtualKeyboard.new(@physical_keyboards)
    @virtual_keyboard.add_transformer(FlagTracker.new)
  end

  def left_keyboard=(left_keyboard)
    @left_keyboard = left_keyboard
    left_keyboard.add_transformer(KeyRemapper.new(49 => 59))
    left_keyboard.add_transformer(KeyCodePrinter.new)
  end
end


include HotCocoa
application do
  @double_keyboard = DoubleKeyboard.new
end

