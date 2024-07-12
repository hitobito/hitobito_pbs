#  Copyright (c) 2012-2018, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::ContactableDecorator
  extend ActiveSupport::Concern

  included do
    def compact_contact_info(only_public = true)
      html = "".html_safe
      html << primary_email
      html << all_phone_numbers(only_public)
      unless html.empty?
        content_tag(:div, html, {class: "well well-small no-margin"})
      end
    end
  end
end
