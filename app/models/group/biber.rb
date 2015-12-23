# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.
# == Schema Information
#
# Table name: groups
#
#  id                     :integer          not null, primary key
#  parent_id              :integer
#  lft                    :integer
#  rgt                    :integer
#  name                   :string(255)      not null
#  short_name             :string(31)
#  type                   :string(255)      not null
#  email                  :string(255)
#  address                :string(1024)
#  zip_code               :integer
#  town                   :string(255)
#  country                :string(255)
#  contact_id             :integer
#  created_at             :datetime
#  updated_at             :datetime
#  deleted_at             :datetime
#  layer_group_id         :integer
#  creator_id             :integer
#  updater_id             :integer
#  deleter_id             :integer
#  pta                    :boolean          default(FALSE), not null
#  vkp                    :boolean          default(FALSE), not null
#  pbs_material_insurance :boolean          default(FALSE), not null
#  website                :string(255)
#  pbs_shortname          :string(15)
#  bank_account           :string(255)
#  description            :text
#

class Group::Biber < Group

  self.event_types = [Event::Camp]

  children Group::Biber,
           Group::AbteilungsGremium

  class Einheitsleitung < ::Role
    self.permissions = [:layer_and_below_read]
  end

  class Mitleitung < ::Role
    self.permissions = [:layer_and_below_read]
  end

  class Adressverwaltung < ::Role
    self.permissions = [:group_full]
  end

  class Biber < ::Role
    self.permissions = []
    self.visible_from_above = false
  end

  roles Einheitsleitung,
        Mitleitung,
        Adressverwaltung,
        Biber

end
