# encoding: utf-8

#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


module EventParticipationsPbsHelper

  def course_confirmation_link(entry, &block)
    entry = entry.decorate
    return nil unless entry.event.course_kind? && entry.has_confirmation?
    form_tag(course_confirmation_url(entry),
             method: :post, style: 'display: inline', authenticity_token: false,
             enforce_utf8: false, target: '_blank') do
      inputs = [capture(&block)]
      entry.course_confirmation_params.entries.each do |key, value|
        inputs << hidden_field_tag(key, preserve(value))
      end
      safe_join(inputs)
    end
  end

  private

  def course_confirmation_url(entry)
    return nil unless entry.event.course_kind?
    sprintf(Settings.application.course_confirmation_url,
            course_kind_confirmation_name:
              entry.event.kind.confirmation_name,
            locale: I18n.locale.to_s)
  end

end
