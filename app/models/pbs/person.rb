# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


# == Schema Information
#
# Table name: people
#
#  id                      :integer          not null, primary key
#  first_name              :string(255)
#  last_name               :string(255)
#  company_name            :string(255)
#  nickname                :string(255)
#  company                 :boolean          default(FALSE), not null
#  email                   :string(255)
#  address                 :string(1024)
#  zip_code                :integer
#  town                    :string(255)
#  country                 :string(255)
#  gender                  :string(1)
#  birthday                :date
#  additional_information  :text
#  contact_data_visible    :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  encrypted_password      :string(255)
#  reset_password_token    :string(255)
#  reset_password_sent_at  :datetime
#  remember_created_at     :datetime
#  sign_in_count           :integer          default(0)
#  current_sign_in_at      :datetime
#  last_sign_in_at         :datetime
#  current_sign_in_ip      :string(255)
#  last_sign_in_ip         :string(255)
#  picture                 :string(255)
#  last_label_format_id    :integer
#  creator_id              :integer
#  updater_id              :integer
#  primary_group_id        :integer
#  salutation              :string(255)
#  title                   :string(255)
#  grade_of_school         :integer
#  entry_date              :date
#  leaving_date            :date
#  j_s_number              :string(255)
#  correspondence_language :string(5)
#  brother_and_sisters     :boolean          default(FALSE), not null
#  failed_attempts         :integer          default(0)
#  locked_at               :datetime
#
module Pbs::Person
  extend ActiveSupport::Concern

  included do
    Person::PUBLIC_ATTRS << :title << :salutation << :correspondence_language << :kantonalverband_id

    alias_method_chain :full_name, :title

    i18n_boolean_setter :brother_and_sisters


    belongs_to :kantonalverband, class_name: 'Group' # might also be Group::Bund


    validates :salutation,
              inclusion: { in: ->(_) { Salutation.available.keys },
                           allow_blank: true }

    validates :correspondence_language,
              inclusion: { in: lambda do |_|
                                 Settings.application.languages.to_hash.keys.collect(&:to_s)
                               end,
                           allow_blank: true }

    validates :entry_date, :leaving_date,
              timeliness: { type: :date, allow_blank: true, before: Date.new(9999, 12, 31) }


    after_save :reset_kantonalverband!, if: :primary_group_id_changed?
  end

  def salutation_label
    Salutation.new(self).label
  end

  def salutation_value
    Salutation.new(self).value
  end

  def pbs_number
    format('%09d', id).gsub(/(\d)(?=(\d\d\d)+(?!\d))/, '\\1-')
  end

  def full_name_with_title(format = :default)
    case format
    when :list then full_name_without_title(format)
    else "#{title} #{full_name_without_title(format)}".strip
    end
  end

  def reset_kantonalverband!
    update_column(:kantonalverband_id, find_kantonalverband.try(:id))
  end

  private

  def find_kantonalverband
    if primary_group
      kantonalverband_for(primary_group)
    else
      kvs = groups.collect { |group| kantonalverband_for(group) }.uniq
      kvs.first if kvs.size == 1
    end
  end

  def kantonalverband_for(group)
    group.hierarchy.select(:id).find_by(type: ::Group::Kantonalverband.sti_name) ||
    Group.select(:id).root
  end
end
