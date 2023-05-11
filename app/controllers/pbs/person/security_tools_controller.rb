
module Pbs::Person::SecurityToolsController
  extend ActiveSupport::Concern

  included do
    before_action :load_groups_and_roles_that_see_me
  end

  def load_groups_and_roles_that_see_me
    @groups_and_roles_that_see_me ||= groups_and_roles_that_see_me
  end

  def groups_and_roles_that_see_me
    groups_and_roles = {}
    Role::TypeList.new(Group.root_types.first).flatten.each do |role|
      all_groups.each do |group_id, group_name, group_type|
        next unless can_see_me?(role, group_id, group_type)

        groups_and_roles[group_id] ||= { name: group_name, roles: [] }
        groups_and_roles[group_id][:roles] << role.label
      end
    end
    groups_and_roles
  end

  def all_groups
    @all_groups ||= Group.order_by_type.pluck(:id, :name, :type)
  end

  def can_see_me?(role, group_id, group_type)
    return false if group_type != role.name.deconstantize

    test_person = Ability.new(Person.new(roles: [role.new(group_id: group_id)]))
    test_person.can?(:show_details, current_user)
  end

end
