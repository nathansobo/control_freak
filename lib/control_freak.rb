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

class PhysicalKeyboard
  def self.all
    DDHidKeyboard.allKeyboards.map do |hid_keyboard|
      PhysicalKeyboard.new(hid_keyboard)
    end
  end

  attr_reader :hid_keyboard, :key_down_node, :key_up_node

  def initialize(hid_keyboard)
    @hid_keyboard = hid_keyboard
    hid_keyboard.delegate = self
    @key_down_node = SubscriptionNode.new
    @key_up_node = SubscriptionNode.new
  end

  def listen
    hid_keyboard.startListening
  end

  def seize
    hid_keyboard.listenInExclusiveMode = true
    listen
  end

  def key_down(code)
    key_down_node.publish(KeyboardEvent.alloc.initWithHIDUsageCode(code, keyDown:true))
  end

  def key_up(code)
    key_up_node.publish(KeyboardEvent.alloc.initWithHIDUsageCode(code, keyDown:false))
  end

  def on_key_down(&proc)
    key_down_node.subscribe(&proc)
  end

  def on_key_up(&proc)
    key_up_node.subscribe(&proc)
  end
end

class VirtualKeyboard
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

  def add_transformer(transformer)
    transformers.push(transformer)
  end

  def key_down(event)
    transformed_event = transformers.inject(event) do |event, transformer|
      transformer.key_down(event) if event
    end
    event_tap.postEvent(transformed_event) if transformed_event
  end

  def key_up(event)
    transformed_event = transformers.inject(event) do |event, transformer|
      transformer.key_up(event) if event
    end

    event_tap.postEvent(transformed_event) if transformed_event
  end
end

class FlagFuser
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
        puts "control"
        @control_flags = KCGEventFlagMaskControl
        nil
      when LeftShift, RightShift
        puts "shift"
        @shift_flags = KCGEventFlagMaskShift
        nil
      when LeftAlt, RightAlt
        puts "shift"
        @alt_flags = KCGEventFlagMaskAlternate
        nil
      when LeftCommand, RightCommand
        @command_flags = KCGEventFlagMaskCommand
        nil
      else
        puts_binary(flags)
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


include HotCocoa
application do
  @virtual_keyboard = VirtualKeyboard.new(PhysicalKeyboard.all)
  @virtual_keyboard.add_transformer(FlagFuser.new)
end

