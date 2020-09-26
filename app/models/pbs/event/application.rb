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

  private

  def initialize_approval
    if participation.present?
      approver = Event::Approver.new(participation.reload)
      approver.application_created
    end
  end

end
