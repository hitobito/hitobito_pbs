# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


module EventsPbsHelper

  def format_event_application_conditions(entry)
    texts = [entry.application_conditions]
    texts.unshift(entry.kind.application_conditions) if entry.course_kind?
    safe_join(texts.select(&:present?).map { |text| simple_format(text) })
  end

  def format_course_languages(entry)
    Event::Course::LANGUAGES.map do |key|
      attr = "language_#{key}"
      if entry.send("#{attr}?")
        I18n.t("events.fields_pbs.#{attr}")
      end
    end.compact.join(', ')
  end

end
