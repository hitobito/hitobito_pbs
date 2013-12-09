# encoding: utf-8
class Group::Biber < Group

  children Group::Biber


  class Einheitsleiter < ::Role
    self.permissions = [:layer_read]
  end

  class Mitleiter < ::Role
    self.permissions = [:layer_read]
  end

  class Adressverwalter < ::Role
    self.permissions = [:group_full]
  end

  class Biber < ::Role
    self.permissions = []
    self.visible_from_above = false
  end

  roles Einheitsleiter,
        Mitleiter,
        Adressverwalter,
        Biber

end