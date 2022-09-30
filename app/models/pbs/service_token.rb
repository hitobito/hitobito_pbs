#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.
# == Schema Information
#
# Table name: service_tokens
#
#  id                   :integer          not null, primary key
#  layer_group_id       :integer          not null
#  name                 :string(255)      not null
#  description          :text(65535)
#  token                :string(255)      not null
#  last_access          :datetime
#  people               :boolean          default(FALSE)
#  people_below         :boolean          default(FALSE)
#  groups               :boolean          default(FALSE)
#  events               :boolean          default(FALSE)
#  event_participations :boolean          default(FALSE)
#  group_health         :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

module Pbs::ServiceToken
  extend ActiveSupport::Concern

  included do
    validates :group_health, absence: true, if: :below_top_layer?
    validates :census_evaluations, absence: true, if: :below_top_layer?
  end

  private

  def below_top_layer?
    Group.find(layer_group_id).class != Group::Bund
  end

end
