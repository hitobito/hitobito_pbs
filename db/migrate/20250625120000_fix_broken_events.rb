# frozen_string_literal: true

#  Copyright (c) 2025, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class FixBrokenEvents < ActiveRecord::Migration[6.1]
  def up
    still_invalid = {}

    say_with_time "cleaning up invalid events" do
      Event.includes(:questions, :groups).find_each do |event|
        next if event.valid? && event.questions.all?(&:valid?)

        event.required_contact_attrs&.reject! { |a| a == 'address' }
        event.required_contact_attrs&.reject! { |a| a == 'correspondence_language' }
        event.hidden_contact_attrs&.reject! { |a| a == 'address' }
        event.hidden_contact_attrs&.reject! { |a| a == 'correspondence_language' }
        event.contact_attrs_passed_on_to_supercamp&.reject! { |a| a == 'address' }
        event.contact_attrs_passed_on_to_supercamp&.reject! { |a| a == 'correspondence_language' }

        clean_up_duplicate_questions!(event)

        event.save!(validate: false) # save without validations, to ignore any remaining user errors

        if !event.valid? # still collect information about the invalid events
          still_invalid[event.id] = event.errors
        end
      end
    end

    still_invalid.each do |event_id, error|
      say("Event #{event_id} is still invalid: #{error.full_messages.join(', ')}")
    end

    say("#{still_invalid.length} events are still invalid due to user errors")
  end

  def clean_up_duplicate_questions!(event)
    questions = event.questions.includes(:answers).where.not(derived_from_question_id: nil)
    find_duplicates(questions).each do |_derived_from, duplicate_questions|
      question_to_keep = duplicate_questions.first
      consolidate_answers!(duplicate_questions, question_to_keep, event)
      duplicate_questions.excluding(question_to_keep).each(&:destroy!)
    end
  end

  def find_duplicates(questions)
    questions
      .select { |q| q.derived_from_question_id.present? }
      .group_by(&:derived_from_question_id)
      .select { |_, v| v.size > 1 }
  end

  def consolidate_answers!(duplicate_questions, target_question, event)
    event.participations.each do |participation|
      answer = target_question.answers.find_or_initialize_by(participation_id: participation.id)
      answer.answer = find_any_answer(duplicate_questions, participation)
      answer.save!
    end
  end

  def find_any_answer(questions, participation)
    questions.find do |question|
      question.answers.find do |a|
        a.participation_id == participation.id && a.answer.present?
      end
    end&.answer
  end
end
