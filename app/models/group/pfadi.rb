# encoding: utf-8
class Group::Pfadi < Group

  children Group::Pfadi

  class Einheitsleiter < ::Role
    self.permissions = [:layer_read]
  end

  class Mitleiter < ::Role
    self.permissions = [:layer_read]
  end

  class Adressverwalter < ::Role
    self.permissions = [:group_full]
  end

  class Leitpfadi < ::Role
    self.permissions = [:group_read]
    self.visible_from_above = false
  end

  class Pfadi < ::Role
    self.permissions = []
    self.visible_from_above = false
  end

  roles Einheitsleiter,
        Mitleiter,
        Adressverwalter,
        Leitpfadi,
        Pfadi

end
