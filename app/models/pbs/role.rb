# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  person_id  :integer          not null
#  group_id   :integer          not null
#  type       :string(255)      not null
#  label      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#
module Pbs::Role
  extend ActiveSupport::Concern

  included do
    self.used_attributes += [:created_at, :deleted_at]

    validates_presence_of :created_at, on: :update

    validates :created_at,
              timeliness: { type: :datetime,
                            on_or_before: :now,
                            allow_blank: true }

    validates :deleted_at,
              timeliness: { type: :datetime,
                            on_or_before: :now,
                            after: ->(role) { role.created_at },
                            allow_blank: true }

    before_create :detect_group_membership_notification
    after_create :send_group_membership_notification
    after_save :update_primary_group
  end

  def created_at=(value)
    super(value)
  rescue ArgumentError
    # could not set value
    super(nil)
  end

  def deleted_at=(value)
    super(value)
  rescue ArgumentError
    # could not set value
    super(nil)
  end

  def detect_group_membership_notification
    @send_notification = false;

    return unless Person.stamper
    @current_user = Person.find(Person.stamper)

    # don't notify newly created users without roles
    p = Person.find(person.id)
    return unless p.roles.exists?

    # manually initialize ability (this is not very beautiful but
    # must be done to detect change in access to person data)
    @send_notification = Ability.new(@current_user).cannot?(:update, p)

    true
  end

  def send_group_membership_notification
    if @send_notification && @current_user
      GroupMembershipJob.new(person, @current_user, group).enqueue!
    end

    true
  end

  def update_primary_group
    if changes.include?(:deleted_at) && changes[:deleted_at].first.nil? && changes[:deleted_at].last
      reset_primary_group
    end
  end
end
