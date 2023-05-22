# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class InsertNewRootGroup < ActiveRecord::Migration[6.1]
  def up
    admin_layer = nil

    say_with_time 'Create new root-group' do
      admin_layer = Group.find_or_create_by(
        name: 'hitobito',
        type: 'Group::Root',
      )
    end

    say_with_time 'Move bund group below new root-group' do
      Group
        .where(type: 'Group::Bund', parent_id: nil)
        .update_all(parent_id: admin_layer.id, lft: nil, rgt: nil)
    end

    say_with_time 'Create new silverscouts group below new root-group' do
      Group::Silverscouts.create(name: 'Silverscouts', short_name: 'SiSc', type: 'Group::Silverscouts')
      Group
        .where(type: 'Group::Silverscouts', parent_id: nil)
        .update_all(parent_id: admin_layer.id, lft: nil, rgt: nil)
    end

    say_with_time 'Rebuilding nested set...' do
      Group.rebuild!(false)
    end
  end

  def down
    admin_layer_ids = Group.where(type: 'Group::Root').pluck(:id)

    say_with_time 'Make current bund root' do
      Group
        .where(type: 'Group::Bund', parent_id: admin_layer_ids)
        .update_all(parent_id: nil, lft: nil, rgt: nil)
    end

    say_with_time 'Remove silverscouts groups' do
      Group.where(type: 'Group::Silverscouts', parent_id: admin_layer_ids).find_each { |g| g.really_destroy! }
    end

    say_with_time 'Rebuilding nested set...' do
      Group.rebuild!(false)
    end
  end
end
