# encoding: utf-8
class Group::Elternrat < Group

  class Praesidium < ::Role
    self.permissions = [:group_full]
  end

  class Mitglied < ::Role
    self.permissions = [:group_read]
  end

  roles Praesidium,
        Mitglied

end
