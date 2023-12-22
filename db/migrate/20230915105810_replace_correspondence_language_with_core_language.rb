# frozen_string_literal: true

# Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
# hitobito_pbs and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https://github.com/hitobito/hitobito_pbs.

class ReplaceCorrespondenceLanguageWithCoreLanguage < ActiveRecord::Migration[6.1]
  CANTONS_LANGUAGE = {
    # de: [:ag, :ai, :ar, :be, :bl, :bs, :gl, :gr, :lu, :nw, :ow, :sg, :sh, :so, :sz, :tg, :ur, :zg, :zh],
    fr: [:fr, :ge, :ju, :ne, :vd, :vs],
    it: [:ti]
  }.freeze

  def up
    Person.where.not(correspondence_language: nil).update_all("language = correspondence_language")
    Person.where(correspondence_language: nil).find_each do |person|
      person.update_attribute(:language, infer_person_language(person))
    end

    remove_column :people, :correspondence_language, :string, limit: 5
  end

  def down
    add_column :people, :correspondence_language, :string, limit: 5
    Person.update_all("correspondence_language = language")
  end

  def infer_person_language(person)
    return person.language if person.language.present?
    return person.correspondence_language if person.try(:correspondence_language).present?

    kv = person.send(:find_kantonalverband)&.becomes(Group::Kantonalverband)
    canton = kv&.kantonalverband_cantons&.first&.to_s&.downcase&.to_sym
    CANTONS_LANGUAGE.find { |language, cantons| cantons.include?(canton) }&.first || :de
  end
end
