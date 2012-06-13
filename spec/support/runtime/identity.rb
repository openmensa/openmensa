require 'identity'

class Identity
  def password=(password)
    @password   = password
    self.secret = password unless password.empty?
  end

  def authenticate(password)
    return secret == password ? self : false
  end
end
