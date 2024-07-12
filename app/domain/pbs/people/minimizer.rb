# frozen_string_literal: true

#  Copyright (c) 2023-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::People::Minimizer
  def minimize
    ActiveRecord::Base.transaction do
      @person.update!(values_for_minimizing)

      minimize_person_relations.each do |relation|
        @person.send(relation).destroy_all
      end

      delete_taggings
    end
  end

  def values_for_minimizing
    minimize_person_attrs.index_with do |attr|
      Person.column_defaults[attr.to_s]
    end
  end

  def delete_taggings
    excluded_subscription_tags = SubscriptionTag.where(tag_id: @person.tag_ids,
      excluded: true)

    taggings_to_delete = @person.taggings
      .where.not(tag_id: excluded_subscription_tags.pluck(:tag_id))

    taggings_to_delete.delete_all
  end

  def minimize_person_attrs # rubocop:disable Metrics/MethodLength
    [
      :address, # TODO: remove this when cleaning up structured addresses
      :street,
      :housenumber,
      :address_care_of,
      :postbox,
      :town,
      :zip_code,
      :title,
      :language,
      :salutation,
      :grade_of_school,
      :entry_date,
      :leaving_date,
      :j_s_number,
      :nationality_j_s,
      :additional_information
    ]
  end

  def minimize_person_relations
    [
      :notes,
      :additional_emails,
      :phone_numbers,
      :social_accounts,
      :family_members
    ]
  end
end
