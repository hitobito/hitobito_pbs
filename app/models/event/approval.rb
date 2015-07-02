# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: event_approvals
#
#  id             :integer          not null, primary key
#  application_id :integer          not null
#  layer          :string(255)      not null
#  approved       :boolean          default(FALSE), not null
#  rejected       :boolean          default(FALSE), not null
#  comment        :text
#  approved_at    :datetime
#  person_id      :integer
#


#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::Approval < ActiveRecord::Base

  LAYERS = %w(abteilung region kantonalverband bund)


  self.demodulized_route_keys = true

  ### ASSOCIATIONS

  belongs_to :application

  has_one :participation, through: :application
  has_one :event, through: :participation
  has_one :person, through: :participation


  ### VALIDATIONS

  validates :layer, inclusion: LAYERS


  class << self

    # List all pending approvals for a given layer group.
    def pending(layer)
      joins(person: :primary_group).
      where('groups.lft >= :lft AND groups.rgt <= :rgt', lft: layer.lft, rgt: layer.rgt).
      where(layer: layer.class.name.demodulize.downcase, approved: false, rejected: false)
    end
  end
end
