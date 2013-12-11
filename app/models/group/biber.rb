# encoding: utf-8
class Group::Biber < Group

  children Group::Biber


  class Einheitsleitung < ::Role
    self.permissions = [:layer_read]
  end

  class Mitleitung < ::Role
    self.permissions = [:layer_read]
  end

  class Adressverwaltung < ::Role
    self.permissions = [:group_full]
  end

  class Biber < ::Role
    self.permissions = []
    self.visible_from_above = false
  end

  roles Einheitsleitung,
        Mitleitung,
        Adressverwaltung,
        Biber

end
