class DDHidKeyboard
  def ddhidKeyboard(keyboard, keyDown: usageId)
    key_down_node.publish(usageId)
  end

  def ddhidKeyboard(keyboard, keyUp: usageId)
    key_up_node.publish(usageId)
  end

  def on_key_down(&proc)
    key_down_node.subscribe(&proc)
  end

  def on_key_up(&proc)
    key_up_node.subscribe(&proc)
  end

  def key_down_node
    @key_down_node ||= ::SubscriptionNode.new
  end

  def key_up_node
    @key_up_node ||= ::SubscriptionNode.new
  end
end
