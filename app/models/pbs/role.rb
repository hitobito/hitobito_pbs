#  Copyright (c) 2012-2018, Pfadibewegung Schweiz. This file is part of
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
    Role::Types::Permissions << :crisis_trigger

    before_create :detect_group_membership_notification
    after_create :send_group_membership_notification
    after_create :send_black_list_mail, if: :person_blacklisted?
  end

  def detect_group_membership_notification
    @send_notification = false

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

  def send_black_list_mail
    BlackListMailer.hit(person, group).deliver_now
  end

  def set_first_primary_group
    super
    person.reload.reset_kantonalverband!
  end

  private

  def person_blacklisted?
    person.black_listed?
  end
end
