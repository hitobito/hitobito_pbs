# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module EventApprovalHelper

  def format_event_approval_approvee(approval)
    link_to(approval.approvee, [@group, @event, approval.participation])
  end

  def format_event_approval_approver(approval)
    layer_label = t("events.application_fields_pbs.requires_approval_#{approval.layer}")
    if approval.approver
      safe_join([link_to(approval.approver, approval.approver), layer_label], ' ')
    else
      layer_label
    end
  end

  def format_event_approval_status(approval)
    prefix = 'event/application_decorator'

    label, type, tooltip =
      if approval.approved?
        %W(&#x2713; success #{t("#{prefix}.confirmation.approved")})
      elsif approval.rejected?
        %W(&#x00D7; important #{t("#{prefix}.confirmation.rejected")})
      else
        %W(? warning #{t("#{prefix}.confirmation.missing")})
      end

    approval_status_badge(label, type, "#{t("#{prefix}.course_acceptance")} #{tooltip}")
  end

  private

  def approval_status_badge(label, type, tooltip)
    options = { class: "badge badge-#{type || 'default'}" }
    if tooltip.present?
      options.merge!(rel: :tooltip,
                     'data-container' => 'body',
                     'data-html' => 'true',
                     'data-placement' => 'bottom',
                     title: tooltip)
    end
    content_tag(:span, label.html_safe, options)
  end

end
