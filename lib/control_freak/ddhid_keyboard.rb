class DDHidKeyboard
  attr_reader :delegate

  # manual implementation to to avoid warning about kvo setter
  def delegate=(delegate)
    @delegate = delegate
  end

  def ddhidKeyboard(keyboard, keyDown: usageId)
    delegate.key_down(usageId) if delegate
  end

  def ddhidKeyboard(keyboard, keyUp: usageId)
    delegate.key_up(usageId) if delegate
  end
end
