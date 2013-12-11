# encoding: utf-8

module Pbs::GroupAbility
  extend ActiveSupport::Concern

  included do
    on(Group) do
      permission(:layer_full).may(:modify_superior).if_mitarbeiter_gs
    end
  end

  def if_mitarbeiter_gs
    user.roles.any? do |r|
      r.is_a?(Group::Bund::MitarbeiterGs)
    end
  end
end
