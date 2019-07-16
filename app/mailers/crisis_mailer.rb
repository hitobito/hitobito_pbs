#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CrisisMailer < ApplicationMailer

  CONTENT_CRISIS_ACKNOWLEDGED = 'content_crisis_acknowledged'.freeze
  CONTENT_CRISIS_TRIGGERED = 'content_crisis_triggered'.freeze

  RECIPIENTS = [Group::Bund::VerantwortungKrisenteam,
                Group::Bund::LeitungKernaufgabeKommunikation]

  attr_reader :crisis

  def triggered(crisis)
    @crisis = crisis

    recipients = bund_recipients
    recipients += kanton_recipients if bund?(crisis.creator)

    compose(recipients, CONTENT_CRISIS_TRIGGERED)
  end

  def acknowledged(crisis, acknowledger)
    @crisis = crisis
    @acknowledger = acknowledger

    compose(bund_recipients + kanton_recipients, CONTENT_CRISIS_ACKNOWLEDGED)
  end

  private

  def bund?(person)
    person.roles.where(type: RECIPIENTS).exists?
  end

  def bund_recipients
    Person.
      joins(:roles).
      where('roles.type IN (?)', RECIPIENTS).
      pluck(:email)
  end

  def kanton_recipients
    kantonalverband = crisis.group.layer_hierarchy.find { |g| g.is_a?(Group::Kantonalverband) }

    Person
      .joins(:roles)
      .where('roles.type = ?', Group::Kantonalverband::VerantwortungKrisenteam.sti_name)
      .where('roles.group_id = ?', kantonalverband.try(:id))
      .pluck(:email)
  end

  def placeholder_group
    link_to(crisis.group, url_for(crisis.group))
  end

  def placeholder_creator
    crisis.creator.full_name
  end

  def placeholder_acknowledger
    @acknowledger.full_name
  end

  def placeholder_date
    Time.now.strftime('%d.%m.%Y %H:%M')
  end

end
