class Ability::Token
  include CanCan::Ability

  def initialize(access_token)
    alias_action :new, :to => :create
    alias_action :edit, :to => :update
    alias_action :delete, :to => :destroy

  end
end
