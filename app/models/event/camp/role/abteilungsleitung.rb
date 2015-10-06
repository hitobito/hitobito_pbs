module Event::Camp::Role
  class Abteilungsleitung < ::Event::Role

    self.permissions = [:participations_read]

    self.kind = nil

  end
end
