# frozen_string_literal: true

class AnonymousUser < User
  validate :single_user

  def single_user
    errors.add_to_base "An anonymous user already exists." if self.class.find_by(login: self.class.login_id)
  end

  def logged?
    false
  end

  def admin?
    false
  end

  def name
    I18n.t(:anonymous_user)
  end

  def last_name
    name
  end

  def email
    nil
  end

  def destroy
    false
  end

  def internal?
    true
  end

  def destructible?
    false
  end
end
