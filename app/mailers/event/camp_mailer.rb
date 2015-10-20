# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::CampMailer < ApplicationMailer

  CONTENT_CAMP_CREATED = 'camp_created'
  CONTENT_COACH_ASSIGNED = 'camp_coach_assigned'
  CONTENT_SECURITY_ADVISOR_ASSIGNED = 'camp_security_advisor_assigned'
  CONTENT_AL_ASSIGNED = 'camp_al_assigned'
  CONTENT_SUBMIT_REMINDER = 'camp_submit_reminder'
  CONTENT_SUBMIT = 'camp_submit'
  CONTENT_PARTICIPANT_APPLIED = 'camp_participant_applied'
  CONTENT_PARTICIPANT_CANCELED = 'camp_participant_canceled'

  attr_reader :camp

  def created_info(camp, recipients, actuator)
    @camp = camp
    compose(CONTENT_CAMP_CREATED, recipients, 'actuator-name' => actuator.to_s)
  end

  def coach_assigned_info(camp, recipients, actuator)
    @camp = camp
    compose(CONTENT_COACH_ASSIGNED, recipients,
            'actuator-name' => actuator.to_s,
            'coach-name' => camp.coach.to_s)
  end

  def security_advisor_assigned_info(camp, recipients, actuator, advisor)
    @camp = camp
    compose(CONTENT_SECURITY_ADVISOR_ASSIGNED, recipients,
            'actuator-name' => actuator.to_s,
            'advisor-name' => advisor.to_s)
  end

  def al_assigned_info(camp, recipients, actuator)
    @camp = camp
    compose(CONTENT_AL_ASSIGNED, recipients,
            'actuator-name' => actuator.to_s,
            'al-name' => camp.abteilungsleitung.to_s)
  end

  def remind(camp, recipient)
    @camp = camp
    compose(CONTENT_SUBMIT_REMINDER, recipient,
            'recipient-name' => recipient.greeting_name)
  end

  def submit(camp, recipient, actuator)
    @camp = camp
    compose(CONTENT_SUBMIT, recipient,
            'recipient-name' => recipient.greeting_name,
            'actuator-name' => actuator.to_s,
            'camp-application-url' => camp_application_url)
  end

  def participant_applied_info(participation, recipients)
    @camp = participation.event
    compose(CONTENT_PARTICIPANT_APPLIED, recipients,
            'participant-name' => participation.person.to_s)
  end

  def participant_canceled_info(participation, recipients)
    @camp = participation.event
    compose(CONTENT_PARTICIPANT_CANCELED, recipients,
            'participant-name' => participation.person.to_s)
  end

  private

  def compose(content_key, recipients, values)
    content = CustomContent.get(content_key)

    values['camp-name'] = camp.name
    values['camp-url'] = camp_url
    values['camp-state'] = camp_state

    mail(to: Person.mailing_emails_for(recipients), subject: content.subject) do |format|
      format.html { render text: content.body_with_values(values) }
    end
  end

  def camp_url
    group_event_url(camp.groups.first, camp)
  end

  def camp_application_url
    camp_application_group_event_url(camp.groups.first, camp)
  end

  def camp_state
    I18n.t("activerecord.attributes.event/camp.states.#{camp.state}")
  end

  def advisor_assigned(camp, advisor, key, user_id)
    # content = CustomContent.get(fetch_advisor_content_key(key))
    # values['event-details']  = event_details
    # ...

    # mail(to: Person.mailing_emails_for(advisor), subject: content.subject) do |format|
    #   format.html { render text: content.body_with_values(values) }
    # end
  end

  def submit_camp(camp)
    # content = CustomContent.get(CONTENT_KEY)
    # values['event-details']  = event_details
    # ...
    recipients = [Settings.email.camp.submit_recipient]
    recipients << Settings.email.camp.submit_abroad_recipient if camp.abroad?

    copies = [camp.coach,
              camp.abteilungsleitung,
              *camp.participations_for(Event::Camp::Role::Leader).collect(&:person)].compact

    # mail(to: recipients,
    #      cc: Person.mailing_emails_for(copies),
    #      subject: content.subject) do |format|
    #   format.html { render text: content.body_with_values(values) }
    # end
  end

  private

  #def fetch_advisor_content(advisor_key)
  #  case advisor_key
  #  when 'coach' then COACH_KEY
  #  when 'abteilungsleitung' then AL_KEY
  #  else
  #    ADVISOR_KEY
  #  end
  #end

end
