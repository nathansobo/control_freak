dir = File.dirname(__FILE__)

require "#{dir}/control_freak/subscription_node"
framework "ApplicationServices"
framework "#{dir}/../ControlFreak.framework"
framework "#{dir}/../DDHidLib.framework"
require "#{dir}/control_freak/ddhid_keyboard"
require "#{dir}/control_freak/event_tap"
require "#{dir}/control_freak/event"


def puts_binary(n)
  puts n.to_s(2).rjust(32, '0')
end

require 'hotcocoa'
include HotCocoa
application do
  @keyboards = DDHidKeyboard.allKeyboards
  @keyboards.each do |kb|
    kb.track_modifier_keys
  end

  @tap = EventTap.new
  @tap.on_event do |event|
    combined_flags = @keyboards.inject(DDHidKeyboard::NO_FLAGS_MASK) do |mask, kb|
      mask | kb.flags
    end
    event.set_flags(event.get_flags | combined_flags)
    event
  end
end

