# encoding: utf-8
class Group::Pfadi < Group

  children Group::Pfadi

  class Einheitsleitung < ::Role
    self.permissions = [:layer_read]
  end

  class Mitleitung < ::Role
    self.permissions = [:layer_read]
  end

  class Adressverwaltung < ::Role
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

  roles Einheitsleitung,
        Mitleitung,
        Adressverwaltung,
        Leitpfadi,
        Pfadi

end
