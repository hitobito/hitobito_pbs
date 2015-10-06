module Event::Camp::Role
  class AdvisorSnowSecurity < ::Event::Role

    self.permissions = [:participations_read]

    self.kind = nil

  end
end
