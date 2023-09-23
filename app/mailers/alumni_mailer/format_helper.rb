# frozen_string_literal: true

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
