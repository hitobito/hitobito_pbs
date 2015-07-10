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
    layer_label = t("events.fields_pbs.requires_approval_#{approval.layer}")
    safe_join([link_to(approval.approver, approval.approver), layer_label], ' ')
  end

  def format_event_approval_status(approval)
    approval.application.decorate.confirmation_label
  end

end
