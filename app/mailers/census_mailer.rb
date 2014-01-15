# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CensusMailer < ActionMailer::Base

  CONTENT_REMINDER   = 'census_reminder'

  helper StandardHelper

  def reminder(sender, census, recipients, abteilung, kalei)
    content = CustomContent.get(CONTENT_REMINDER)
    values = content_values(census, recipients, abteilung, kalei)

    mail to: recipients.collect(&:email),
         return_path: return_path(sender),
         sender: return_path(sender),
         reply_to: sender,
         subject: content.subject do |format|
      format.html { render text: content.body_with_values(values) }
    end
  end

  private

  def content_values(census, recipients, abteilung, kalei)
    {
      'due-date'        => due_date(census),
      'recipient-names' => recipients.collect(&:first_name).join(', '),
      'contact-address' => contact_address(kalei),
      'census-url'      => "<a href=\"#{census_url(abteilung)}\">#{census_url(abteilung)}</a>"
    }
  end

  def due_date(census)
    I18n.l(census.finish_at)
  end

  def census_url(abteilung)
    population_group_url(abteilung)
  end

  def contact_address(group)
    return '' if group.nil?

    address = [group.to_s]
    address << group.address.to_s.gsub("\n", '<br/>').presence
    address << [group.zip_code, group.town].compact.join(' ').presence
    address << group.phone_numbers.where(public: true).collect(&:to_s).join('<br/>').presence
    address << group.email
    address.compact.join('<br/>')
  end

  def return_path(sender)
    MailRelay::Lists.personal_return_path(MailRelay::Lists.app_sender_name, sender)
  end
end
