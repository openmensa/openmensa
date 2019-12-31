# frozen_string_literal: true

if defined?(ActiveModel)
  def be_able_to(actions, object, name = nil)
    CancanMatcher.new(actions.is_a?(Array) ? actions : [actions], object, name)
  end
end

class CancanMatcher # :nodoc:
  def initialize(actions, object, name)
    @actions = actions
    @object  = object
    @name    = name
    @action  = '<unknown>'
  end

  def matches?(user)
    @actions.each do |a|
      @action = a
      return false unless user.can?(a, @object)
    end
    true
  end

  def does_not_match?(user)
    @actions.each do |a|
      return false unless user.cannot?(a, @object)
    end
    true
  end

  def failure_message
    "Should be able to #{@action} #{@name} #{@object.inspect}"
  end

  def failure_message_when_negated
    "Should not be able to #{@action} #{@name} #{@object.inspect}"
  end

  def description
    "be able to #{@actions.join(', ')} #{@name || @object}"
  end
end
