# encoding: utf-8
class Group::TopLayer < Group

  self.layer = true


  class Administrator < Role
    self.permissions = [:admin, :layer_full]
  end

  class Leader < Role::Leader
  end

  class Member < Role::Member
  end

  roles Administrator, Leader, Member, Role::External
end
