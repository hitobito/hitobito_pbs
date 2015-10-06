module Event::Camp::Role
  class AssistantLeader < ::Event::Role

    self.permissions = [:event_full, :participations_full]

    self.kind = :leader

  end
end
