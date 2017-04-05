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
#  approver_id    :integer
#

class Event::Approval < ActiveRecord::Base

  # ordering matters
  LAYERS = %w(abteilung region kantonalverband bund).freeze

  self.demodulized_route_keys = true

  ### ASSOCIATIONS

  belongs_to :application
  belongs_to :approver, class_name: 'Person'

  has_one :participation, through: :application
  has_one :event, through: :participation
  has_one :approvee, through: :participation, source: :person


  ### VALIDATIONS

  validates_by_schema
  validates :layer, inclusion: LAYERS, uniqueness: { scope: :application_id }
  validates :current_occupation, :current_level, :occupation_assessment,
            :strong_points, :weak_points,
            presence: { if: :approved? }

  def roles
    layer_class.roles.select { |role| role.permissions.include?(:approve_applications) }
  end

  def layer_class
    "Group::#{layer.classify}".constantize
  end

  def status
    return :approved if approved?
    return :rejected if rejected?
  end

  class << self

    # List all pending approvals for a given layer group.
    def pending(layer)
      joins(approvee: :primary_group).
        where('groups.lft >= :lft AND groups.rgt <= :rgt', lft: layer.lft, rgt: layer.rgt).
        where(layer: layer.class.name.demodulize.downcase, approved: false, rejected: false)
    end

    # List all complted approvals for a given course.
    def completed(course)
      joins(:approvee, :event).
        where(events: { id: course.id }).
        where('event_approvals.rejected = ? or event_approvals.approved = ?', true, true)
    end
  end

end
