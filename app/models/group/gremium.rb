# encoding: utf-8
class Group::Gremium < Group

  children Group::Gremium


  class Leitung < ::Role
    self.permissions = [:group_full]
  end

  class Mitglied < ::Role
    self.permissions = [:group_read]
  end

  roles Leitung, Mitglied

end
