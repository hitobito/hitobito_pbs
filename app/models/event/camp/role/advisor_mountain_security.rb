module Event::Camp::Role
  class AdvisorMountainSecurity < ::Event::Role

    self.permissions = [:participations_read]

    self.kind = nil

  end
end
