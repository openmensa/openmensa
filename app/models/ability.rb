class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :new, :to => :create
    alias_action :edit, :to => :update
    alias_action :delete, :to => :destroy

    # admin can do whatever he wants
    if user.admin?
      can :manage, :all
      cannot :destroy, User, :admin? => true

      return
    end

    if user.logged?
      can :show, User, :id => user.id
    end
  end
end
