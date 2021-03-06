# encoding: utf-8

#  Copyright (c) 2012-2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Participation

  extend ActiveSupport::Concern

  included do
    after_create :send_black_list_mail, if: :person_blacklisted?
  end

  def approvers
    Person.where(id: application && application.approvals.collect(&:approver_id))
  end

  private

  def send_black_list_mail
    BlackListMailer.hit(person, event).deliver_now
  end

  def person_blacklisted?
    person.black_listed?
  end
end
