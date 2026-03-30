module Pbs::ApiScopeAbility
  extend ActiveSupport::Concern

  def acceptable_special_case?(subject_class_name, action)
    if subject_class_name == "Group" && action.to_sym == :"index_event/camps"
      return acceptable?(:events)
    end
    super
  end
end
