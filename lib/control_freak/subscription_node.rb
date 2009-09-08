class SubscriptionNode
  attr_reader :subscriptions
  def initialize
    @subscriptions = []
  end

  def subscribe(&proc)
    subscriptions.push(proc)
  end

  def publish(val)
    retval = nil
    subscriptions.each do |subscription|
      retval = subscription.call(val)
    end
    retval
  end
end
