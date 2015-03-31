class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :new, to: :create
    alias_action :edit, to: :update
    alias_action :delete, to: :destroy

    can :show, Canteen
    can :fetch, Canteen

    if user.logged?
      can [:show, :update], User, id: user.id
      can :manage, Identity, user_id: user.id
      can :manage, Favorite, user_id: user.id
    end

    if user.developer?
      can :manage, Canteen, user_id: user.id
      can :manage, Message, canteen: {user_id: user.id}
    end

    # admin can do whatever he wants
    if user.admin?
      can :manage, :all
      cannot :destroy, User, admin?: true
    end
  end
end
