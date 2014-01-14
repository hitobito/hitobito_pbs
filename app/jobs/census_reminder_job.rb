# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CensusReminderJob < BaseJob

  self.parameters = [:census, :sender, :abteilung_id]

  attr_reader :census, :sender

  def initialize(sender, census, abteilung)
    @census = census
    @sender = sender.email
    @abteilung_id = abteilung.id
  end

  def perform
    r = recipients.to_a
    CensusMailer.reminder(sender, census, r, abteilung, kalei).deliver if r.present?
  end

  def recipients
    abteilung.people.only_public_data.
                     where(roles: { type: Group::Abteilung::Abteilungsleitung.sti_name }).
                     where("email IS NOT NULL OR email <> ''").
                     uniq
  end

  def abteilung
    @abteilung ||= Group::Abteilung.find(@abteilung_id)
  end

  def kalei
    state = abteilung.kantonalverband
  end
end
