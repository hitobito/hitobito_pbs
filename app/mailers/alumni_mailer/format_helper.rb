# encoding: utf-8
# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AlumniMailer::FormatHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Context
  include Rails.application.routes.url_helpers

  def initialize(default_url_options)
    @default_url_options = default_url_options # used for path helpers
  end

  def group_selfinscription_links(groups, &block)
    content_tag(:ul) do
      groups.each_with_object([]) do |group, links|
        links << content_tag(:li) { group_selfinscription_link(group, &block) }
      end.join.html_safe
    end
  end

  def group_selfinscription_link(group, &block)
    url = group_self_registration_url(group_id: group, target: '_blank')
    label = block.call(group)
    link_to(label, url).html_safe
  end

  private

  # used for path helpers
  def controller; end

end
