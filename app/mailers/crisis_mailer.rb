#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CrisisMailer < ApplicationMailer

  CONTENT_CRISIS_ACKNOWLEDGED = 'content_crisis_acknowledged'.freeze
  CONTENT_CRISIS_TRIGGERED = 'content_crisis_triggered'.freeze
  CONTENT_CRISIS_COMPLETED = 'content_crisis_completed'.freeze

  RECIPIENTS = [Group::Bund::VerantwortungKrisenteam,
                Group::Bund::LeitungKernaufgabeKommunikation]

  attr_reader :crisis

  def acknowledged(crisis, acknowledger)
    @crisis = crisis
    @acknowledger = acknowledger

    compose(recipients, CONTENT_CRISIS_ACKNOWLEDGED)
  end

  def triggered(crisis)
    @crisis = crisis

    compose(recipients, CONTENT_CRISIS_TRIGGERED)
  end

  def completed(crisis)
    @crisis = crisis
    recipient = crisis.group.email

    compose(recipient, CONTENT_CRISIS_COMPLETED)
  end


  private

  def recipients
    Person.
      joins(:roles).
      where('roles.type IN (?)', RECIPIENTS).
      pluck(:email)
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
