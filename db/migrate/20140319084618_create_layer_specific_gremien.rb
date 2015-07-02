# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CreateLayerSpecificGremien < ActiveRecord::Migration
  def up
    update_group_types('Group::Gremium',
                       [[Group::Bund, Group::BundesGremium],
                        [Group::Kantonalverband, Group::KantonalesGremium],
                        [Group::Region, Group::RegionalesGremium],
                        [Group::Abteilung, Group::AbteilungsGremium]])

    update_group_types('Group::Rover',
                       [[Group::Region, Group::RegionaleRover],
                        [Group::Abteilung, Group::AbteilungsRover]])
  end

  def down
    # no down path
  end

  private

  def update_group_types(old_type, new_types)
    updateable_ids = Group.where(type: old_type).
                           pluck(:id, :layer_group_id)
    layers = Group.where(id: updateable_ids.collect(&:last).uniq).
                   group_by(&:type)

    new_types.each do |layer_type, new_type|
      update_layer_gremien(updateable_ids, layers, layer_type, new_type)
    end
  end

  def update_layer_gremien(updateable_ids, layers, layer_type, new_type)
    if (current = layers[layer_type.sti_name].presence)
      ids = extract_layer_groups(updateable_ids, current)
      Group.where(id: ids).update_all(type: new_type.sti_name)

      update_role_types(ids, new_type)
    end
  end

  def extract_layer_groups(updateable_ids, layers)
    layer_ids = layers.collect(&:id)
    updateable_ids.select { |id, layer_id| layer_ids.include?(layer_id) }.
                   collect(&:first)
  end

  def update_role_types(group_ids, group_type)
    typed_roles = Role.where(group_id: group_ids).group_by(&:type)
    typed_roles.each do |type, roles|
      Role.where(id: roles.collect(&:id)).update_all(type: "#{group_type}::#{type.demodulize}")
    end
  end

end
