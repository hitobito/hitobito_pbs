#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: groups
#
#  id                          :integer          not null, primary key
#  parent_id                   :integer
#  lft                         :integer
#  rgt                         :integer
#  name                        :string(255)      not null
#  short_name                  :string(31)
#  type                        :string(255)      not null
#  email                       :string(255)
#  address                     :string(1024)
#  zip_code                    :integer
#  town                        :string(255)
#  country                     :string(255)
#  contact_id                  :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  deleted_at                  :datetime
#  layer_group_id              :integer
#  creator_id                  :integer
#  updater_id                  :integer
#  deleter_id                  :integer
#  require_person_add_requests :boolean          default(FALSE), not null
#  pta                         :boolean          default(FALSE), not null
#  vkp                         :boolean          default(FALSE), not null
#  pbs_material_insurance      :boolean          default(FALSE), not null
#  website                     :string(255)
#  pbs_shortname               :string(15)
#  bank_account                :string(255)
#  description                 :text
#  application_approver_role   :string
#  gender                      :string(1)
#  try_out_day_at              :date
#
module Pbs::Group
  extend ActiveSupport::Concern

  included do
    self.used_attributes += [:website, :bank_account, :pbs_shortname]
    self.superior_attributes = [:pbs_shortname]

    Group::SEARCHABLE_ATTRS << :pbs_shortname << :description << :website << :bank_account
    include PgSearchable

    validates :description, length: {allow_nil: true, maximum: 2**16 - 1}
    validates :hostname, uniqueness: true, allow_blank: true
    has_many :crises

    root_types Group::Root

    def self.bund
      Group::Bund.first
    end

    def self.silverscouts
      Group::Silverscouts.first
    end
  end

  def active_crisis_acknowledgeable?(person)
    active_crisis && !active_crisis.acknowledged && active_crisis.creator != person
  end

  def active_crisis
    @active_crisis ||= crises.active.first
  end

  def pending_approvals?
    pending_approvals_count > 0
  end

  def pending_approvals_count
    @pending_approvals_count ||= Event::Approval.pending(self).count
  end

  def census?
    respond_to?(:census_total)
  end

  def require_person_add_requests
    true
  end

  alias_method :require_person_add_requests?, :require_person_add_requests
end
