# encoding: utf-8
class Group::Rover < Group

  children Group::Rover


  class Einheitsleiter < ::Role
    self.permissions = [:layer_read]
  end

  class Mitleiter < ::Role
    self.permissions = [:layer_read]
  end

  class Adressverwalter < ::Role
    self.permissions = [:group_full]
  end

  class Rover < ::Role
    self.permissions = []
    self.visible_from_above = false
  end

  roles Einheitsleiter,
        Mitleiter,
        Adressverwalter,
        Rover

end