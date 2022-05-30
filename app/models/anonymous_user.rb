# frozen_string_literal: true

class AnonymousUser < User
  validate :single_user

  def single_user
    errors.add_to_base "An anonymous user already exists." if self.class.find_by(login: "anonymous")
  end

  def logged?
    false
  end

  def admin?
    false
  end

  def email
    nil
  end

  def internal?
    true
  end

  def destructible?
    false
  end
end
