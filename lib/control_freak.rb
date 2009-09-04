dir = File.dirname(__FILE__)

require "#{dir}/control_freak/subscription_node"
framework "ApplicationServices"
framework "#{dir}/../ControlFreak.framework"
framework "#{dir}/../DDHidLib.framework"
require "#{dir}/control_freak/ddhid_keyboard"
require "#{dir}/control_freak/xkeys_pedal"
require "#{dir}/control_freak/event_tap"
require "#{dir}/control_freak/event"


def puts_binary(n)
  puts n.to_s(2).rjust(32, '0')
end

require 'hotcocoa'
include HotCocoa
application do
  @tap = EventTap.new
  @xkeys = XkeysPedal.new

  @xkeys.left_flags = KCGEventFlagMaskAlternate
  @xkeys.middle_flags = KCGEventFlagMaskControl
  @xkeys.right_flags = KCGEventFlagMaskCommand

  @tap.on_event do |event|
    puts_binary(@xkeys.active_flags)
    event
  end

end

