# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Application
  extend ActiveSupport::Concern

  included do
    belongs_to :waiting_list_setter, class_name: 'Person'

    has_many :approvals, dependent: :destroy

    after_create :initialize_approval
  end

  def next_open_approval
    approvals.find_by(approved: false, rejected: false)
  end

  def current_status_label
    if approvals.select(&:rejected).any?
      I18n.t('event.applications.current_status_rejected')
    elsif approvals_missing?
      I18n.t('event.applications.current_status_approvals_missing')
    elsif participation.active == false
      I18n.t('event.applications.current_status_inactive')
    end
  end

  private

  def initialize_approval
    if participation.present?
      approver = Event::Approver.new(participation.reload)
      approver.request_approvals
    end
  end

  def approvals_missing?
    %w(abteilung region kantonalverband bund).any? do |layer|
      event["requires_approval_#{layer}"] &&
        approvals.select { |a| a.layer == layer && a.approved }.none?
    end
  end

end
