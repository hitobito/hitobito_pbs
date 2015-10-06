module Event::Camp::Role
  class LeaderMountainSecurity < ::Event::Role

    self.permissions = [:participations_read]

    self.kind = :leader

  end
end
