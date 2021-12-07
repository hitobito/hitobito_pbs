# frozen_string_literal: true

# Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
# hitobito_pbs and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https://github.com/hitobito/hitobito_pbs.

class RevertSuperfluousProlongations2021 < ActiveRecord::Migration[6.0]

  # Reverts the prolongation of some of the J+S qualifications which were mistakenly prolonged
  # due to COVID-19. Only participants should get the prolongation, not the course organizers.

  QUALIFICATION_KIND_LABELS =
    ['J+S Leiter*in LS/T Kindersport',
     'J+S Leiter*in LS/T Jugendsport'].freeze

  # Reset the prolonged date back to the original value
  PROLONGED_DATE = Date.new(2021, 12, 31).freeze

  def up
    js_quali_courses_2021.find_each do |c|
      participant_ids = c.participations.
          where(qualified: true).
          # Revert the prolongation for all participants which had only leader roles in the course
          select {|participation| participation.roles.none? { |role| role.class.participant? } }.
          collect(&:person_id)
      qualis = Qualification.where(person_id: participant_ids,
                                   qualification_kind_id:
                                   qualification_kind_ids,
                                   start_at: c.qualification_date)
      qualis.update_all(finish_at: PROLONGED_DATE)
    end
  end

  private

  def js_quali_courses_2021
    Event::Course
      .joins(:dates)
      .joins(:kind)
      .includes(:participations)
      .between(Date.new(2019, 1, 1), Date.new(2019, 12, 31))
      .where(event_kinds: { id: js_event_kind_ids })
  end

  def js_event_kind_ids
    Event::KindQualificationKind
      .where(qualification_kind_id: qualification_kind_ids, role: 'participant')
      .pluck(:event_kind_id)
  end

  def qualification_kind_ids
    @qualification_kind_ids ||=
      QualificationKind
      .where(label: QUALIFICATION_KIND_LABELS)
      .pluck(:id)
  end

end
