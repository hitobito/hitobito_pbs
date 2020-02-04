# encoding: utf-8

#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationDecorator
  extend ActiveSupport::Concern

  def course_confirmation_form(&block)
    return nil unless event.course_kind? && has_confirmation?
    h.form_tag(course_confirmation_url,
             method: :post, style: 'display: inline', authenticity_token: false,
             enforce_utf8: false, target: '_blank') do
      inputs = [h.capture(&block)]
      course_confirmation_params.entries.each do |key, value|
        inputs << h.hidden_field_tag(key, h.preserve(value))
      end
      safe_join(inputs)
    end
  end

  def has_confirmation?
    event.can_have_confirmations? && event.has_confirmations? &&
      participant? && active? && qualified?
  end

  private

  def participant?
    roles.map(&:class).any?(&:participant?)
  end

  def course_confirmation_params
    {
      name: person.last_name,
      vorname: person.first_name,
      anrede: person.title,
      wohnort: person.town,
      geburtstag: person.birthday ? person.birthday.strftime(I18n.t('date.formats.default')) : nil,
      kursOrt: event.location,
      dauer: event.dates ? event.dates.map {|d| d.duration.to_s(:short)}.join(', ') : '',
      organisator: event.group_names,
    }
  end

  def course_confirmation_url
    return nil unless event.course_kind?
    sprintf(Settings.application.course_confirmation_url,
            course_kind_confirmation_name: event.kind.confirmation_name,
            locale: I18n.locale.to_s)
  end

end
