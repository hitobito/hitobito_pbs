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
