class EventTap
  def handleEvent(event)
    event_node.publish(event) || event
  end

  def on_event(&proc)
    event_node.subscribe(&proc)
  end

  def event_node
    @event_node ||= SubscriptionNode.new
  end

  def ready?
    !eventTapProxy.nil?
  end
end
