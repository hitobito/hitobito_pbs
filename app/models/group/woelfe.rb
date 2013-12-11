# encoding: utf-8
class Group::Woelfe < Group

  children Group::Woelfe

  class Einheitsleitung < ::Role
    self.permissions = [:layer_read]
  end

  class Mitleitung < ::Role
    self.permissions = [:layer_read]
  end

  class Adressverwaltung < ::Role
    self.permissions = [:group_full]
  end

  class Wolf < ::Role
    self.permissions = []
    self.visible_from_above = false
  end

  roles Einheitsleitung,
        Mitleitung,
        Adressverwaltung,
        Wolf

end
