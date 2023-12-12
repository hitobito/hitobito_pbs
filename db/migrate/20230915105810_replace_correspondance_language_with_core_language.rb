class ReplaceCorrespondanceLanguageWithCoreLanguage < ActiveRecord::Migration[6.1]
  CANTONS_LANGUAGE = {
    # de: [:ag, :ai, :ar, :be, :bl, :bs, :gl, :gr, :lu, :nw, :ow, :sg, :sh, :so, :sz, :tg, :ur, :zg, :zh],
    fr: [:fr, :ge, :ju, :ne, :vd, :vs],
    it: [:ti]
  }.freeze

  def up
    Person.update_all("language = correspondence_language")
    remove_column :people, :correspondence_language, :string, limit: 5

    Person.where(language: nil).find_each do |person|
      person.update!(language: infer_person_language(person))
    end
  end

  def infer_person_language(person)
    return person.language if person.language.present?

    canton = person.find_kantonalverband&.kantonalverband_cantons&.first&.to_sym
    CANTONS_LANGUAGE.find { |language, cantons| cantons.include?(canton) }&.first || :de
  end
end
