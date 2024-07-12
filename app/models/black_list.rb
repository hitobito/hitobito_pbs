#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: black_lists
#
#  id                     :integer          not null, primary key
#  first_name             :string
#  last_name              :string
#  pbs_number             :string
#  email                  :string
#  phone_number           :string
#  reference_name         :string
#  reference_phone_number :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class BlackList < ActiveRecord::Base
  validates :email, format: Devise.email_regexp, allow_blank: true
  validates :first_name, :last_name, :reference_name, :reference_phone_number, presence: true
  validates :pbs_number, format: {with: /\A\d{3}-\d{3}-\d{3}\z/}

  validates_by_schema

  def to_s
    self.class.model_name.human
  end
end
