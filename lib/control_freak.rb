framework "/Users/nathansobo/Documents/ControlFreak/build/Release/ControlFreak.framework"

class EventHandler
  def onEvent(event)
    puts "onEvent in ruby"
  end
end

require 'hotcocoa'
include HotCocoa
application do
  @tap = EventTap.alloc.initForEventTypes([])
  @handler = EventHandler.new
  @tap.delegate = @handler
end