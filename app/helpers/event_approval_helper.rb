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
    layer_label = format_event_approval_layer(approval)
    if approval.approver
      safe_join([link_to(approval.approver, approval.approver), layer_label], ' ')
    else
      layer_label
    end
  end

  def format_event_approval_layer(approval)
    t("events.application_fields_pbs.requires_approval_#{approval.layer}")
  end

  def format_event_approval_status(approval)
    args = @participation.application.approval_fields(approval.approved?, approval.rejected?)
    badge(*args)
  end

  def consolidated_approval_occupations(approvals)
    labels = approvals.map do |a|
      label = a.current_occupation.to_s.strip
      label += " (#{a.current_level.strip})" if a.current_level?
      label.presence
    end.compact.uniq.sort

    safe_join(labels) do |l|
      content_tag(:p, l)
    end
  end

end
